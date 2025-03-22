import 'package:dartz/dartz.dart';
import 'package:videostream/core/usecases/failer.dart';
import 'package:videostream/features/home/data/data_source/streamhome_api_service.dart';
import 'package:videostream/features/home/data/model/video_model.dart';
import 'package:videostream/features/home/domain/entities/video_entity.dart';
import 'package:videostream/features/home/domain/repos/video_repository.dart';

class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;

  VideoRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<VideoEntity>>> fetchVideos(
      {int page = 0, String? filterTag}) async {
    try {
      List<VideoModel> videos =
          await remoteDataSource.fetchVideos(page, filterTag);
      return Right(videos);
    } catch (e) {
      throw Exception("Failed to fetch videos: $e");
    }
  }

  @override
  Future<bool> uploadStatus() async {
    try {
      bool videos = await remoteDataSource.uploadStatus();
      return videos;
    } catch (e) {
      throw Exception("Failed to fetch videos");
    }
  }

  @override
  Future<List<VideoEntity>> fetchRandomVideos() async {
    try {
      List<VideoModel> videos = await remoteDataSource.fetchRandomVideo();
      return videos;
    } catch (e) {
      throw Exception("Failed to fetch 5 videos: $e");
    }
  }
}
