import 'package:videostream/features/home/domain/entities/video_entity.dart';
import 'package:videostream/features/home/domain/repos/video_repository.dart';

class GetRandomVideosHomeUseCase {
  final VideoRepository repository;

  GetRandomVideosHomeUseCase(this.repository);

  Future<List<VideoEntity>> call() {
    return repository.fetchRandomVideos();
  }
}
