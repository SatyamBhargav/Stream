import 'package:videostream/features/ground_zero/domain/repo/zero_repo.dart';

class CheupdateUsecase {
  final VidoePickerRepo repository;
  CheupdateUsecase(this.repository);
  Future<List> call() async {
    return await repository.getLatestVersion();
  }
}
