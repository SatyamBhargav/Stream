import 'dart:io';

import 'package:videostream/core/datasource/uploadfile_service.dart';
import 'package:videostream/core/repo/uploadfile_repo.dart';

class UploadFileRepositoryImpl implements UploadFileRepository {
  final UploadFileServiceSource
      apiClient; // Assume you have an API client for HTTP calls

  UploadFileRepositoryImpl(this.apiClient);

  @override
  Future<void> uploadFile(
      File uploadFile, bool thumbnail, bool categoryImage) async {
    try {
      await apiClient.uploadFile(uploadFile, thumbnail, categoryImage);
    } catch (e) {
      throw Exception('error during impl $e');
    }
  }
}
