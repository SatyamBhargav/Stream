import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:videostream/core/usecases/failer.dart';
import 'package:videostream/features/home/domain/entities/video_entity.dart';
import 'package:videostream/features/home/domain/repos/video_repository.dart';

// class GetVideosHomeUseCase {
//   final VideoRepository repository;

//   GetVideosHomeUseCase(this.repository);

//   Future<List<VideoEntity>> call() async {
//     final videos = await repository.getVideos();

//     // Sort videos by date (latest first)
//     // final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
//     // videos.sort((a, b) {
//     //   DateTime dateA = dateFormat.parse(a.date!);
//     //   DateTime dateB = dateFormat.parse(b.date!);
//     //   return dateB.compareTo(dateA);
//     // });

//     return videos;
//   }
// }
class GetVideosHomeUseCase {
  final VideoRepository repository;

  GetVideosHomeUseCase(this.repository);


  Future<Either<Failure, List<VideoEntity>>> call({required int page, String? filterTag}) {
    return repository.fetchVideos(page: page, filterTag: filterTag);
  }
}





// class FetchVideos {
//   final VideoRepository repository;

//   FetchVideos(this.repository);

//   Future<Either<Failure, List<VideoEntity>>> call({required int page, String? filterTag}) {
//     return repository.fetchVideos(page: page, filterTag: filterTag);
//   }
// }

