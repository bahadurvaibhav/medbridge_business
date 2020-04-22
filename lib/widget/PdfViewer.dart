import 'package:flutter/material.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

class MyPdfViewer extends StatelessWidget {
  final String pdfPath;
  final String fileName;

  MyPdfViewer(this.pdfPath, this.fileName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: PdfViewer(filePath: pdfPath),
    );
  }
}
