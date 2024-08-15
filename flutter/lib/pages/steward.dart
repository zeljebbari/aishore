import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database.dart';
import '../widgets/appbar.dart';
import '../providers/config.dart';

class StewardPage extends StatefulWidget {
  const StewardPage({super.key, required this.title});
  final String title;

  @override
  State<StewardPage> createState() => _StewardPageState();
}

class _StewardPageState extends State<StewardPage> {
  final _formKey = GlobalKey<FormState>();
  final _borrowerFirstController = TextEditingController();
  final _borrowerMController = TextEditingController();
  final _borrowerLastController = TextEditingController();
  String? _selectedDocumentType;
  final _entityController = TextEditingController();
  bool _showEntityNameField = false;
  List _results = [];
  final threshold = .65;

  Future<double> _fetchConfidence(String url) async {
    final baseUrl = getBaseUrl();
    final confidenceUrl = Uri.parse('$baseUrl/send_confidence');
    final response = await http.post(
      confidenceUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({'URL': url}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['send_confidence'] ?? 0.0;
    } else {
      throw Exception('Failed to fetch confidence');
    }
  }
  final Color validatedColor = const Color.fromRGBO(0, 143, 75, 1.0);
  final Color needsValidationColor = const Color.fromRGBO(198, 52, 2, 1.0);

  Future<void> _search() async {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Searching...'),
          duration: Duration(seconds: 30),
        ),
      );
      final baseUrl = getBaseUrl();
      final url = Uri.parse('$baseUrl/steward');
      final payload = {
        'borrower_first_name': _borrowerFirstController.text,
        'borrower_m_name': _borrowerMController.text,
        'borrower_last_name': _borrowerLastController.text,
        'doc_type': _selectedDocumentType ?? '',
        'entity_name': _showEntityNameField ? _entityController.text : '',
      };
      try {
        final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode(payload),
        );
        if (response.statusCode == 200) {
          List results = jsonDecode(response.body);
          for (var result in results) {
            result['confidence'] = await _fetchConfidence(result['url']);
          }
          setState(() {
            _results = results;
          });
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          if (_results.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No results found.')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Search completed successfully!'), 
                duration: Duration(seconds: 5),
              ),
            );
          }
        } else {
          throw Exception('Failed to load data: ${response.statusCode}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: SelectableText('Error fetching data: $e')),
        );
      }
    } 
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.'), duration: Duration(seconds: 15),),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LogoAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(35.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Center(
                    child: Text(
                      'Data Steward Portal',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _borrowerFirstController,
                          decoration: const InputDecoration(
                            labelText: 'Borrower First Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter borrower\'s first name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 9.0),
                      Expanded(
                        child: TextFormField(
                          controller: _borrowerMController,
                          decoration: const InputDecoration(
                            labelText: 'Borrower Middle Initial',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 9.0),
                      Expanded(
                        child: TextFormField(
                          controller: _borrowerLastController,
                          decoration: const InputDecoration(
                            labelText: 'Borrower Last Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter borrower\'s last name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _selectedDocumentType,
                    items: const [
                      DropdownMenuItem(value: 'ID', child: Text('ID')),
                      DropdownMenuItem(value: 'Loan Application', child: Text('Loan Application')),
                      DropdownMenuItem(value: 'FICO', child: Text('FICO')),
                      DropdownMenuItem(value: 'Background Check', child: Text('Background Check')),
                      DropdownMenuItem(value: 'Appraisal', child: Text('Appraisal')),
                      DropdownMenuItem(value: 'Flood Cert', child: Text('Flood Cert')),
                      DropdownMenuItem(value: 'PEXP', child: Text('PEXP')),
                      DropdownMenuItem(value: 'Other', child: Text('Other'))
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDocumentType = value;
                        _showEntityNameField = value == 'Loan Application';
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Select Document Type',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a document type';
                      }
                      return null;
                    },
                  ),
                  if (_showEntityNameField) ...[
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _entityController,
                      decoration: const InputDecoration(
                        labelText: 'Entity Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _search,
                    child: const Text('Search'),
                  ),
                  const SizedBox(height: 32.0),
                  _results.isNotEmpty
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Name', style: TextStyle(fontSize: 17))),
                              DataColumn(label: Text('Document Name', style: TextStyle(fontSize: 17))),
                              DataColumn(label: Text('Document Type', style: TextStyle(fontSize: 17))),
                              DataColumn(label: Text('Entity', style: TextStyle(fontSize: 17))),
                              DataColumn(label: Text('Processing', style: TextStyle(fontSize: 17))),
                              DataColumn(label: Text('View', style: TextStyle(fontSize: 17))),
                            ],
                            rows: _results.map((result) {
                              return DataRow(
                                cells: [
                                  DataCell(Text('${result['borrower_first_name']} ${result['borrower_m_name'].isNotEmpty ? '${result['borrower_m_name']}. ' : ''}${result['borrower_last_name']}')),
                                  DataCell(Text(result['name'])),
                                  DataCell(Text(result['doc_type'])),
                                  DataCell(Text(result['entity_name'].isNotEmpty ? result['entity_name']! : 'N/A')),
                                  DataCell(
                                    SizedBox.expand(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: .5, vertical: .5),
                                        decoration: BoxDecoration(
                                          color: (double.parse(result['confidence'].toString()) > threshold) ? validatedColor : needsValidationColor,
                                          borderRadius: BorderRadius.circular(5.0),
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text((double.parse(result['confidence'].toString()) > threshold) ? 'Validated' : 'Needs Validation'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DatabasePage(
                                              borrowerFirstName: result['borrower_first_name'],
                                              borrowerMName:result['borrower_m_name'],
                                              borrowerLastName:result['borrower_last_name'],
                                              docType: result['doc_type'],
                                              entityName: result['entity_name'] ?? '',
                                              docName: result['name'],
                                              docUrl: result['url'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Select Document'),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        )
                      : const Text('No results found'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
