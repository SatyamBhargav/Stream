import 'package:videostream/features/ground_zero/domain/repo/zero_repo.dart';

class DownloadUpdateUsecase {
  final VidoePickerRepo repository;
  DownloadUpdateUsecase(this.repository);

  Future<void> call( Function(int) onProgress) async{
    return await repository.downloadUpdate( onProgress);
  }
}

