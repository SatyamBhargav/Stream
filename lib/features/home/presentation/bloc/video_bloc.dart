import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:videostream/core/usecases/failer.dart';
import 'package:videostream/features/home/domain/entities/video_entity.dart';
import 'package:videostream/features/home/domain/usecase/get_videos_usecase.dart';
import 'video_event.dart';
import 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final GetVideosHomeUseCase fetchVideos;

  VideoBloc(this.fetchVideos) : super(VideoInitial()) {
    on<FetchVideosEvent>(_onFetchVideos);
    on<FilterVideosEvent>(_onFilterVideos);
  }

  List<VideoEntity> allVideos = [];
  int currentPage = 0;
  bool isFetching = false;
  String? currentFilter;

  Future<void> _onFetchVideos(
      FetchVideosEvent event, Emitter<VideoState> emit) async {
    if (isFetching) return;
    isFetching = true;

    // If it's the first page, show loading indicator
    if (event.page == 0) {
      emit(VideoLoading());
      allVideos.clear();
    }

    final Either<Failure, List<VideoEntity>> result =
        await fetchVideos(page: event.page, filterTag: event.filterTag);

    result.fold(
      (failure) => emit(VideoError(failure.message)),
      (videos) {
        final hasMore = videos.length == 10;

        if (event.page == 0) {
          // First page: replace allVideos
          allVideos = videos;
        } else {
          // Add new videos to the existing list
          allVideos.addAll(videos);
        }

        emit(VideoLoaded(
            videos: List.from(allVideos),
            hasMoreVideos: hasMore)); // Ensure new instance

        currentPage = event.page; // Update current page
      },
    );

    isFetching = false;
  }

  Future<void> _onFilterVideos(
      FilterVideosEvent event, Emitter<VideoState> emit) async {
    currentFilter = event.filterTag;
    add(FetchVideosEvent(page: 0, filterTag: currentFilter));
  }
}
