import 'dart:io'; // dart:io를 사용하여 로컬 파일 시스템 접근

import 'package:flutter/material.dart';

class ImageResultScreen extends StatelessWidget {
  final File? imageFile;

  ImageResultScreen({this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generated Image'),
      ),
      body: Center(
        child: imageFile != null
            ? Image.file(imageFile!)
            : Text('No image generated'),
      ),
    );
  }
}
