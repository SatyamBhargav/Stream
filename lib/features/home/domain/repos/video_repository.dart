import 'package:videostream/core/usecases/failer.dart';
import 'package:videostream/features/home/domain/entities/video_entity.dart';
import 'package:dartz/dartz.dart';

abstract class VideoRepository {
  Future<Either<Failure, List<VideoEntity>>> fetchVideos(
      {int page, String? filterTag});
  Future<bool> uploadStatus();

}
