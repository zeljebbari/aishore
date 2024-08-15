import 'package:ffint/pages/uploaded.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../widgets/appbar.dart';
import '../providers/config.dart';


class AnalystPage extends StatefulWidget {
  const AnalystPage({super.key, required this.title});
  final String title;

  @override
  State<AnalystPage> createState() => _AnalystPageState();
}

class _AnalystPageState extends State<AnalystPage> {
  final _formKey = GlobalKey<FormState>();
  final _entityController = TextEditingController();
  final _borrowerFirstController = TextEditingController();
  final _borrowerMController = TextEditingController();
  final _borrowerLastController = TextEditingController();
  String? _docTypeSelect;
  String? _docTypeOther; 
  PlatformFile? _fileUp;
  String? _selectedFileName;

  // limit  files that can be picked
  void _pickFile() async{
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, 
      allowedExtensions: ['pdf', 'png', 'jpeg', 'jpg']
      );
    if (result != null && result.files.single.bytes != null){
      setState(() {
        _fileUp = result.files.first;
        _selectedFileName = _fileUp!.name;
      });
    }
  }

  // upload files and the relevant data of the form
  Future<void> _uploadFile() async{
    if (_formKey.currentState!.validate() && _fileUp != null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uploading file...'), 
          duration: Duration(seconds:1),
        ),
      );
      try{
        final baseUrl = getBaseUrl();
        print('Using Base URL: $baseUrl');
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/analyst'),
        );
        if (_entityController.text.isNotEmpty) {
          request.fields['entity_name'] = _entityController.text;
        }
        request.fields['borrower_first_name'] = _borrowerFirstController.text;
        request.fields['borrower_m_name'] = _borrowerMController.text;
        request.fields['borrower_last_name'] = _borrowerLastController.text;
        request.fields['doc_type'] = _docTypeSelect ?? '';
        if (_docTypeSelect == "Other") {
          request.fields['doc_type_other'] = _docTypeOther ?? '';
        } 
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            _fileUp!.bytes!,
            filename: _fileUp!.name,
          ),
        );
        var response = await request.send();
        var responseHttp = await http.Response.fromStream(response);
        var responseData = responseHttp.body;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (responseHttp.statusCode==200){
          var json = jsonDecode(responseData);
          var filename = json['file_url'].split('/').last;
          final baseUrl = getBaseUrl();
          var sasResponse = await http.get(
            Uri.parse('$baseUrl/analyst/$filename'),
          );
          if (sasResponse.statusCode == 200) {
            var sasJson = jsonDecode(sasResponse.body);
            var sasUrl = sasJson['file_url'];
            var blobsUrl = json['file_url'];
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File uploaded successfully'),
                duration: Duration(milliseconds: 1500),
              ),
            );
            _entityController.clear(); 
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadedPage(
                  signedUrl: sasUrl,
                  blobUrl: blobsUrl,
                  fileName: filename,
                  entityName: _entityController.text,
                  borrowerFirstName: _borrowerFirstController.text,
                  borrowerMName: _borrowerMController.text,
                  borrowerLastName: _borrowerLastController.text,
                  docType: _docTypeSelect ?? '',
                  docTypeOther: _docTypeOther ?? '',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to get SAS URL')),
            );
          }
        }else {
          String errorMessage;
          try {
            String errorData = responseData.split('message": "')[1];
            errorData = errorData.split('"status"')[0];
            errorData = errorData.trim();
            errorMessage = errorData.split('",')[0];
          } catch (e) {
            errorMessage = '';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SelectableText('Failed to upload file: $errorMessage'),
            ),
          );
        }
      } 
      catch (error) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed. Error: $error'),
          ),
        );
      }
    } 
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and choose a file to upload.'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  InputDecoration tooltipHover(String label, String tooltip) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      suffixIcon: Tooltip(
        message: tooltip,
        child: const Icon(Icons.info_outline, size: 18, color: Colors.blue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LogoAppBar(),
      body: Center(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(35.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget> [
                const Center(
                  child: Text(
                    'Financial Analyst Portal',
                    style: TextStyle(
                      fontSize: 32, 
                    ),
                  ),
                ),
                const SizedBox(height: 32.0), 
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _borrowerFirstController,
                        decoration: tooltipHover(
                          'Borrower First Name',
                          'Enter the borrower\'s legal first name as it appears on official documents.\nNote only characters a-z A-Z 0-9 - _ : . are allowed.'
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter borrowers first name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 9.0),
                    Expanded(
                      child: TextFormField(
                        controller: _borrowerMController,
                        decoration: tooltipHover(
                          'Borrower Middle Initial',
                          'Enter the borrower\'s legal middle initial as it appears on official documents if available.\nNote only characters a-z A-Z 0-9 - _ : . are allowed.'
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
                        decoration: tooltipHover(
                          'Borrower Last Name',
                          'Enter the borrower\'s legal last name as it appears on official documents.\nNote only characters a-z A-Z 0-9 - _ : . are allowed.'
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter borrowers first name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField <String>(
                  value: _docTypeSelect,
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
                  onChanged: (value){
                    setState(() {
                      _docTypeSelect=value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select Document Type',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty){
                      return 'Please select a document type';
                    }
                    return null;
                  },
                ),
                if (_docTypeSelect == "Other")
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: TextFormField(
                      decoration: tooltipHover(
                        'Specify document type if not in options listed',
                        'Enter the document type as listed on the document.\nNote only characters a-z A-Z 0-9 - _ : . are allowed.'
                      ),
                      onChanged: (value){
                        setState(() {
                          _docTypeOther = value;
                        });
                      },
                      validator: (value){
                        if (_docTypeSelect == "Other" && (value == null || value.trim().isEmpty)){
                          return 'Please specify document type if other';
                        }
                        return null;
                      },
                    ),
                  ),
                const SizedBox(height: 16.0),
                if (_docTypeSelect == "Loan Application")
                  TextFormField(
                    controller: _entityController,
                    decoration: tooltipHover(
                      'Entity Name',
                      'Enter the entity or company name as it appears on official documents.\nNote only characters a-z A-Z 0-9 - _ : . are allowed.'
                    ),
                    validator: (value) {
                      if (_docTypeSelect == "Loan Application" && (value == null|| value.trim().isEmpty)) {
                        return 'Please enter entity name';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16.0),
                Tooltip(
                  message: 'Select a PDF, PNG, JPEG, or JPG file to upload.',
                  child: ElevatedButton(
                    onPressed: _pickFile,
                    child: const Text('Select File'),
                  ),
                ),
                if (_selectedFileName != null)
                  Padding(padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Selected file: $_selectedFileName'),
                  ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _uploadFile,
                      child: const Text('Click to Upload'),
                    ),
                    const Icon(Icons.file_upload_outlined),
                  ]
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}