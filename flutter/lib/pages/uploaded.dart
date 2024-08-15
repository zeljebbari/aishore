import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import '../widgets/appbar.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../providers/config.dart';


class UploadedPage extends StatefulWidget {
  final String signedUrl;
  final String blobUrl;
  final String fileName;
  final String entityName;
  final String borrowerFirstName;
  final String borrowerMName;
  final String borrowerLastName;
  final String docType;
  final String docTypeOther;

  const UploadedPage({
    super.key,
    required this.signedUrl,
    required this.blobUrl,
    required this.fileName,
    required this.entityName,
    required this.borrowerFirstName,
    required this.borrowerMName,
    required this.borrowerLastName,
    required this.docType,
    required this.docTypeOther,
  });

  @override
  State<UploadedPage> createState() => _UploadedPageState();
}

class _UploadedPageState extends State<UploadedPage> {
  bool hasError = false;
  String errorMessage = '';

  bool isPDF(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }
  bool isImage(String url) {
    return url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg') ||
        url.toLowerCase().endsWith('.png');
  }
  Future<void> _openPDF() async {
    final url = widget.signedUrl;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
      html.Url.revokeObjectUrl(url);
    } else {
      throw 'Failed to load file';
    }
  }

  Widget _displayFile() {
    if (isPDF(widget.blobUrl)) {
      return hasError
              ? Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(errorMessage),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _openPDF,
                      child: const Text('Open PDF in New Tab'),
                    )
                ],)
              )
              : SizedBox(
                  height: 500,
                  child: SfPdfViewer.network(
                    widget.signedUrl,
                    onDocumentLoadFailed: (details) {
                      setState(() {
                        errorMessage = '${details.error}: ${details.description}';
                        hasError = true;
                      });
                    },
                  ),
                );
    } else if (isImage(widget.blobUrl)) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
        child: CachedNetworkImage(
          imageUrl: widget.signedUrl,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          fit: BoxFit.contain,
        ),
      );
    }
    else {
      return const Text("unsupported file type");
    }
  }

Future<void> deleteFile() async {
  try {
    final baseUrl = getBaseUrl();
    var response = await http.delete(Uri.parse('$baseUrl/analyst/delete/${widget.fileName}'));
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File upload undone successfully'),
          duration: Duration(seconds: 2), 
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete file')),
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed. Error: $error'),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LogoAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30.0),
              const Text(
                'File uploaded successfully!',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 16.0),
              SelectableText(
                'Borrower Name: ${widget.borrowerFirstName} ${widget.borrowerMName.isNotEmpty ? '${widget.borrowerMName}. ' : ''}${widget.borrowerLastName}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8.0),
              SelectableText(
                'Document Type: ${widget.docType}',
                style: const TextStyle(fontSize: 16),
              ),
              if (widget.docType == 'Other' && widget.docTypeOther.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SelectableText(
                    'Specified Document Type: ${widget.docTypeOther}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              const SizedBox(height: 8.0),
              SelectableText(
                'Document Name: ${widget.fileName}',
                style: const TextStyle(fontSize: 16),
              ),
              if ((widget.docType == 'FICO' || widget.docType == 'Loan_App') && widget.entityName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SelectableText(
                    'Entity Name: ${widget.entityName}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              const SizedBox(height: 24.0),
              _displayFile(),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: deleteFile,
                child: const Text('Undo Upload'),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); 
                },
                child: const Text('Upload Another File'),
              ),
              const SizedBox(height: 35.0),
            ],
          ),
        ),
      ),
    );
  }
}
