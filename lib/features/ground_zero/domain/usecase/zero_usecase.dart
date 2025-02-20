import 'package:videostream/features/ground_zero/domain/entities/zero_entity.dart';
import 'package:videostream/features/ground_zero/domain/repo/zero_repo.dart';

class GetZeroUsecase {
  final VidoePickerRepo repository;
  GetZeroUsecase(this.repository);

  Future<VidoePickerEntity> call() {
    return repository.fetchVidoeFile();
  }
  
}