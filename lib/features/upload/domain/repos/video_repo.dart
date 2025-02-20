import 'package:videostream/features/upload/domain/entities/videos.dart';

abstract class UploadRepository {
  Future<void> uploadData(UploadDataEntities uploadData);
}
