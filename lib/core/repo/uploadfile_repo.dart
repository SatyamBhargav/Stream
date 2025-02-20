import 'dart:io';

abstract class UploadFileRepository {
  Future<void> uploadFile(File uploadFile, bool thumbnail, bool categoryImage);
}
