import 'package:videostream/features/upload/domain/entities/videos.dart';
import 'package:videostream/features/upload/domain/repos/video_repo.dart';

class UploadVideoUseCase {
  final UploadRepository _uploadRepository;

  UploadVideoUseCase(this._uploadRepository);

  Future<void> call(UploadDataEntities databaseData) async {
    return await _uploadRepository.uploadData(databaseData);
  }
}
