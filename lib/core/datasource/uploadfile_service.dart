import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

abstract class UploadFileServiceSource {
  Future<void> uploadFile(File upload, bool thumbnail, bool categoryImage);
}

class UploadFileServiceSourceImpl implements UploadFileServiceSource {
  @override
  Future<void> uploadFile(
      File upload, bool thumbnail, bool categoryImage) async {
    final uri = thumbnail
        ? Uri.parse('http://192.168.1.114:5000/thumbnail')
        : categoryImage
            ? Uri.parse('http://192.168.1.114:5000/star')
            : Uri.parse('http://192.168.1.114:5000/upload');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        upload.path,
        filename: basename(upload.path),
      ));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        if (kDebugMode) {
          log('Video uploaded successfully');
        }
      } else {
        if (kDebugMode) {
          log('Failed to upload video. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error uploading video: $e');
      }
    }
  }
}
