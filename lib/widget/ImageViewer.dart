import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatelessWidget {
  final String path;
  final String fileName;

  ImageViewer(this.path, this.fileName);

  @override
  Widget build(BuildContext context) {
    // add appbar inside scaffold
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: Container(
          child: PhotoView(
        imageProvider: FileImage(File(path)),
      )),
    );
  }
}
