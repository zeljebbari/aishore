import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/config.dart';

class DatabasePage extends StatefulWidget {
  const DatabasePage({
    super.key, 
    required this.borrowerFirstName,
    required this.borrowerMName, 
    required this.borrowerLastName,
    required this.docName,
    required this.docType,
    required this.docUrl,
    required this.entityName});
  final String borrowerFirstName;
  final String borrowerMName;
  final String borrowerLastName;
  final String docType;
  final String entityName;
  final String docName;
  final String docUrl;
  
  @override
  State<DatabasePage> createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {
  List<Map<String, dynamic>> _results = [];
  Map<int, String> _newValues = {}; 
  bool hasErrorPDF = false;
  String errorMessage = '';
  late PdfViewerController _pdfViewerController;
  bool isLoading = true;
  double _pdfZoomLevel = 1.0;

  void zoom() {
    setState(() {
      if (_pdfZoomLevel == 1.0) {
        _pdfViewerController.zoomLevel = 1.75;
        _pdfZoomLevel = 1.75;
      } else {
        _pdfZoomLevel = 1.0;
        _pdfViewerController.zoomLevel = 1;
      }
    });
  }
  Future<void> _searchDocuments() async {
    setState(() {
      isLoading = true; 
    });
    final baseUrl = getBaseUrl();
    final url = Uri.parse('$baseUrl/database');
    final payload = {
      'URL': widget.docUrl,
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
        setState(() {
          _results = List<Map<String, dynamic>>.from(json.decode(response.body));
          _newValues = {};
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching document details: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateValue(int id, String? newValue) async {
    if (newValue == null || newValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New value cannot be empty')),
      );
      return;
    }
    final baseUrl = getBaseUrl();
    final url = Uri.parse('$baseUrl/newvalue');
    final payload = {
      'ID': id,
      'PairValue': newValue,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully')),
        );
        _searchDocuments(); 
      } else {
        throw Exception('Failed to save changes');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving changes: $e')),
      );
    }
  }

  Future<void> _openFile() async {
    final response = await http.get(Uri.parse(widget.docUrl));
    if (response.statusCode == 200) {
      // final blob = html.Blob([response.bodyBytes], 'application/pdf');
      final blob = html.Blob([response.bodyBytes], getMimeType());
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
      html.Url.revokeObjectUrl(url);
    } else {
      throw 'Failed to load file';
    }
  }
  bool isPDF(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }
  bool isImage(String url) {
    return url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg') ||
        url.toLowerCase().endsWith('.png');
  }
  String getMimeType() {
    final extension = widget.docUrl.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
        return 'image/jpg';
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        throw 'Unsupported file type';
    }
  }
  Widget _displayFile() {
    if (isPDF(widget.docUrl)) {
      return Expanded(
              flex: 1,
              child: Stack(
                children: [
                  hasErrorPDF
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(errorMessage),
                            const SizedBox(height: 15,),
                            SelectableText.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Open File URL',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                      fontFamily: 'Avenir',
                                      fontSize: 16,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        _openFile();
                                      },
                                  ),
                                  const TextSpan(
                                    text: ' or copy-paste the following link into your browser: \n',
                                    style: TextStyle (fontFamily: 'Avenir', fontSize: 16),
                                  ),
                                  TextSpan(
                                    text: widget.docUrl,
                                    style: const TextStyle (fontFamily: 'Avenir', fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    : SfPdfViewer.network(
                        widget.docUrl,
                        onDocumentLoadFailed: (details) {
                          setState(() {
                            errorMessage = '${details.error}\n${details.description}';
                            hasErrorPDF = true;
                          });
                        },
                        controller: _pdfViewerController,
                      ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        zoom();
                      },
                      child: Text(_pdfZoomLevel == 1.0 ? 'Zoom In' : 'Zoom Out'),
                    )
                  )
                ],
              )
    );
    } else if (isImage(widget.docUrl)) {
      return Expanded(
      flex: 1,
      child: CachedNetworkImage(
        imageUrl: widget.docUrl,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // const Icon(Icons.error),
                Text(errorMessage),
                const SizedBox(height: 10,),
                SelectableText.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Open Image',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontFamily: 'Avenir',
                          fontSize: 16,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _openFile();
                          },
                      ),
                      const TextSpan(
                        text: ' or copy-paste the following link into your browser: \n',
                        style: TextStyle (fontFamily: 'Avenir', fontSize: 16),
                      ),
                      TextSpan(
                        text: widget.docUrl,
                        style: const TextStyle (fontFamily: 'Avenir', fontSize: 16),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        fit: BoxFit.contain, 
      ),
    );
  } else {
    return const Expanded(
      flex: 1,
      child: Center(
        child: SelectableText("Unsupported file type"),
      ),
    );
  }
}

  final List<Color> confidenceColors = const [
    Color.fromRGBO(198, 52, 2, 1.0),
    Color.fromRGBO(188, 62, 8, 1.0),
    Color.fromRGBO(171, 79, 18, 1.0),
    Color.fromRGBO(152, 99, 30, 1.0),
    Color.fromRGBO(137, 115, 39, 1.0),
    Color.fromRGBO(116, 136, 52, 1.0),
    Color.fromRGBO(107, 146, 58, 1.0),
    Color.fromRGBO(88, 165, 70, 1.0),
    Color.fromRGBO(60, 169, 74, 1),
    Color.fromRGBO(0, 143, 75, 1.0),
  ];  
  Color confidenceColor(double confidence) {
    int index = (confidence * (confidenceColors.length - 1)).floor();
    double fraction = (confidence * (confidenceColors.length - 1)) - index;
    if (index >= confidenceColors.length - 1) {
      return confidenceColors.last;
    }
    return Color.lerp(confidenceColors[index], confidenceColors[index + 1], fraction)!;
  }

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LogoAppBar(),
      body: Center(
        child: 
          Padding(
          padding: const EdgeInsets.all(35.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: <Widget> [
              const Center(
                child: Text(
                  'Data Steward Database Portal',
                  style: TextStyle(
                    fontSize: 32, 
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget> [
                                SelectableText(
                                  'Borrower Name: ${widget.borrowerFirstName} ${widget.borrowerMName.isNotEmpty ? '${widget.borrowerMName}. ' : ''}${widget.borrowerLastName}',
                                  style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 5.0), 
                                SelectableText('Document Name: ${widget.docName}', style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 5.0), 
                                SelectableText('Document Type: ${widget.docType}', style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 5.0),
                                if (widget.entityName.isNotEmpty) ...[
                                  const SizedBox(height: 5.0),
                                  SelectableText(
                                    'Entity Name: ${widget.entityName}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                                const SizedBox(height: 25.0), 
                                isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : _results.isNotEmpty
                                    ? SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columnSpacing: 33.0,
                                          columns: const [
                                            DataColumn(label: Text('Key', style: TextStyle(fontSize: 17),),),
                                            DataColumn(label: Text('Value', style: TextStyle(fontSize: 17),),),
                                            DataColumn(label: Text('Confidence', style: TextStyle(fontSize: 17),),),
                                            DataColumn(label: Text('New Value', style: TextStyle(fontSize: 17),),),
                                            DataColumn(label: Text('Edit', style: TextStyle(fontSize: 17),),),
                                            DataColumn(label: Text('Page', style: TextStyle(fontSize: 17),),),
                                          ],
                                          rows: _results.map((result) {
                                            final index = _results.indexOf(result);
                                            return DataRow(
                                              cells: [
                                                DataCell(Text(result['PairKey'] ?? '')),
                                                DataCell(Text(result['PairValue'] ?? '')),
                                                DataCell(
                                                    SizedBox.expand(
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: .5, vertical: .5),
                                                          decoration: BoxDecoration(
                                                            color: confidenceColor(result['Confidence']),
                                                            borderRadius: BorderRadius.circular(5.0), 
                                                          ),
                                                          child: Align(
                                                            alignment: Alignment.centerLeft,
                                                            child: Text(result['Confidence'].toString(),
                                                            ),
                                                          ),
                                                        ),
                                                    ),
                                                ),
                                                DataCell(
                                                  TextFormField(
                                                    initialValue: _newValues[index] ?? '',
                                                    decoration: const InputDecoration(
                                                      hintText: 'Enter new value',
                                                      border: InputBorder.none,
                                                    ),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _newValues[index] = value;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                DataCell(
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        _updateValue(result['ID'], _newValues[index]);
                                                      },
                                                      child: const Text('Save'), // Save Changes
                                                    ),
                                                ),
                                                DataCell(
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        _pdfViewerController.jumpToPage(int.parse(result['Page']));
                                                        _pdfZoomLevel = 1.0;
                                                        _pdfViewerController.zoomLevel = 1;
                                                      },
                                                      child: const Icon(Icons.find_in_page),
                                                    ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      )
                                    : const Text('No results found'),
                                const SizedBox(height: 60),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('View Another Document'),
                            )
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(thickness: 1, color: Colors.grey),
                    _displayFile(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}