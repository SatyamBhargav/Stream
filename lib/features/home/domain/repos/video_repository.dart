import 'package:videostream/core/usecases/failer.dart';
import 'package:videostream/features/home/domain/entities/video_entity.dart';

// abstract class VideoRepository {
//   Future<List<VideoEntity>> getVideos();
//   Future<bool> uploadStatus();
// }

import 'package:dartz/dartz.dart';

abstract class VideoRepository {
  Future<Either<Failure, List<VideoEntity>>> fetchVideos(
      {int page, String? filterTag});
  Future<bool> uploadStatus();

}
