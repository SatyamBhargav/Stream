import 'package:videostream/features/videoplayer/domain/entities/video_player_entity.dart';

abstract class SubtitleRepository {
  Future<SubtitleEntity> getSubtitle();
}
