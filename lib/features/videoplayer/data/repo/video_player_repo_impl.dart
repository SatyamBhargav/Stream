import 'package:videostream/features/videoplayer/data/data_source/subtitle_service.dart';
import 'package:videostream/features/videoplayer/data/model/video_player_model.dart';
import 'package:videostream/features/videoplayer/domain/entities/video_player_entity.dart';
import 'package:videostream/features/videoplayer/domain/repos/video_player_repo.dart';

class SubtitleRepoImpl implements SubtitleRepository {
  final SubtitleDataSource subtitleDataSource;

  SubtitleRepoImpl(this.subtitleDataSource);

  @override
  Future<SubtitleEntity> getSubtitle() async {
    try {
      SubtitleModel subtitles = await subtitleDataSource.getSubtitle();
      return subtitles;
    } catch (e) {
      throw Exception("Failed to fetch subtitles");
    }
  }
}
