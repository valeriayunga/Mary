import 'package:flutter/material.dart';

class MyPdfViewer extends StatelessWidget {
  const MyPdfViewer({super.key, required String pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("PDF View"),
      ),
    );
  }
}