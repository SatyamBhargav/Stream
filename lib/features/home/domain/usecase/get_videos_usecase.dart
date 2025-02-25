import 'package:dartz/dartz.dart';
import 'package:videostream/core/usecases/failer.dart';
import 'package:videostream/features/home/domain/entities/video_entity.dart';
import 'package:videostream/features/home/domain/repos/video_repository.dart';

class GetVideosHomeUseCase {
  final VideoRepository repository;

  GetVideosHomeUseCase(this.repository);


  Future<Either<Failure, List<VideoEntity>>> call({required int page, String? filterTag}) {
    return repository.fetchVideos(page: page, filterTag: filterTag);
  }
}

