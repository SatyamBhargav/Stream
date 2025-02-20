import 'package:videostream/features/home/domain/repos/video_repository.dart';

class UploadStatusUsecase {
  final VideoRepository repository;

  UploadStatusUsecase(this.repository);

  Future<bool> call() async {
    return await repository.uploadStatus();
  }
}
