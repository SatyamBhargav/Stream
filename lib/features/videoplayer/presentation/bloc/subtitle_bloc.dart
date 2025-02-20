import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:videostream/features/videoplayer/domain/entities/video_player_entity.dart';
import 'package:videostream/features/videoplayer/domain/usecases/get_subtitle_usecase.dart';

part 'subtitle_event.dart';
part 'subtitle_state.dart';

class SubtitleBloc extends Bloc<SubtitleEvent, SubtitleState> {
  final List<SubtitleEntity> _subtitles = [];
  final GetSubtitleUseCase getSubtitleUseCase;
  SubtitleBloc(this.getSubtitleUseCase) : super(SubtitleInitial()) {
    on<FetchSubtitle>(_onFetchSubtitle);
    on<UpdateSubtitle>(_onUpdateSubtitle);
  }

  void _onFetchSubtitle(
      FetchSubtitle event, Emitter<SubtitleState> emit) async {
    try {
      final subtitles = await getSubtitleUseCase();
      _subtitles.add(subtitles);
      emit(SubtitleLoaded(
        subtitles.subtitles!,
        currentSubtitle: subtitles.subtitles![0]['text'],
      ));
    } catch (e) {
      emit(SubtitleError(e.toString()));
    }
  }

  void _onUpdateSubtitle(UpdateSubtitle event, Emitter<SubtitleState> emit) {
    if (_subtitles.isEmpty) return;

    String? newSubtitle;
    for (var subtitle in _subtitles.first.subtitles!) {
      // Extract the map list
      if (event.currentTime >= subtitle['start'] &&
          event.currentTime <= subtitle['end']) {
        newSubtitle = subtitle['text'];
        break;
      }
    }

    if (state is SubtitleLoaded) {
      final currentState = state as SubtitleLoaded;
      if (currentState.currentSubtitle != newSubtitle) {
        emit(SubtitleLoaded(_subtitles.first.subtitles!,
            currentSubtitle: newSubtitle));
      }
    }
  }
}
