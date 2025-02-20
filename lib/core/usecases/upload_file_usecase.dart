import 'dart:io';

import 'package:videostream/core/repo/uploadfile_repo.dart';

class UploadFileUseCase {
  final UploadFileRepository _uploadRepository;

  UploadFileUseCase(this._uploadRepository);

  Future<void> call(File uploadFile, bool thumbnail, bool categoryImage) async {
    return await _uploadRepository.uploadFile(
        uploadFile, thumbnail, categoryImage);
  }
}
