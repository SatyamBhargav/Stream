import 'package:videostream/features/ground_zero/domain/entities/zero_entity.dart';

abstract class VidoePickerRepo {
  Future<VidoePickerEntity> fetchVidoeFile();
  Future<List> getLatestVersion();
  Future<void> downloadUpdate(Function(int) onProgress);
}
