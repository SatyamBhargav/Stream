import 'package:videostream/features/videoplayer/domain/entities/video_player_entity.dart';
import 'package:videostream/features/videoplayer/domain/repos/video_player_repo.dart';

class GetSubtitleUseCase {
  final SubtitleRepository repository;

  GetSubtitleUseCase(this.repository);

  Future<SubtitleEntity> call() {
    return repository.getSubtitle();
  }
}
