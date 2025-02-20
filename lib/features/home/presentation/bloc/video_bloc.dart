// // // import 'dart:developer';

// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:videostream/features/home/domain/entities/video_entity.dart';
// // import 'package:videostream/features/home/domain/usecase/filter_video_usecase.dart';
// // import 'package:videostream/features/home/domain/usecase/get_videos_usecase.dart';
// // import 'video_event.dart';
// // import 'video_state.dart';

// // class VideoBloc extends Bloc<VideoEvent, VideoState> {
// //   final GetVideosHomeUseCase getVideosHomeUseCase;
// //   final FilterVideosUseCase filterVideosUseCase;
// //   List<VideoEntity> allVideos = [];

// //   VideoBloc(this.getVideosHomeUseCase, this.filterVideosUseCase)
// //       : super(VideoInitial()) {
// //     on<FetchVideos>(_onFetchVideos);
// //     on<FilterVideos>(_onFilterVideos);
// //   }

// //   void _onFetchVideos(FetchVideos event, Emitter<VideoState> emit) async {
// //     emit(VideoLoading());
// //     try {
// //       final videos = await getVideosHomeUseCase();
// //       allVideos = videos; // Store all videos
// //       emit(VideoLoaded(videos)); // Emit initial state
// //     } catch (e) {
// //       emit(VideoError(e.toString()));
// //     }
// //   }

// //   void _onFilterVideos(FilterVideos event, Emitter<VideoState> emit) {
// //     if (state is VideoLoaded) {
// //       final filteredVideos = filterVideosUseCase(allVideos, event.filterLabel);
// //       emit(VideoLoaded(filteredVideos, selectedFilter: event.filterLabel));
// //     }
// //   }
// // }

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:videostream/features/home/domain/entities/video_entity.dart';
// // import 'package:videostream/features/home/domain/usecase/filter_video_usecase.dart';
// import 'package:videostream/features/home/domain/usecase/get_videos_usecase.dart';
// import 'video_event.dart';
// import 'video_state.dart';

// class VideoBloc extends Bloc<VideoEvent, VideoState> {
//   final GetVideosHomeUseCase getVideosHomeUseCase;
//   // final FilterVideosUseCase filterVideosUseCase;

//   List<VideoEntity> allVideos = [];
//   List<VideoEntity> displayedVideos = [];
//   int currentPage = 0;
//   final int videosPerPage = 10;
//   bool isLoadingMore = false;

//   VideoBloc(this.getVideosHomeUseCase)
//       : super(VideoInitial()) {
//     on<FetchVideos>(_onFetchVideos);
//     on<LoadMoreVideos>(_onLoadMoreVideos);
//     // on<FilterVideos>(_onFilterVideos);
//   }

//   void _onFetchVideos(FetchVideos event, Emitter<VideoState> emit) async {
//     emit(VideoLoading());
//     try {
//       final videos = await getVideosHomeUseCase();
//       allVideos = videos;
//       displayedVideos = allVideos.take(videosPerPage).toList();
//       currentPage = 1;
//       emit(VideoLoaded(displayedVideos));
//     } catch (e) {
//       emit(VideoError(e.toString()));
//     }
//   }

//   void _onLoadMoreVideos(LoadMoreVideos event, Emitter<VideoState> emit) async {
//     if (isLoadingMore || displayedVideos.length >= allVideos.length) return;

//     isLoadingMore = true;
//     emit(VideoLoadingMore(displayedVideos));

//     await Future.delayed(const Duration(seconds: 1));

//     final nextVideos = allVideos
//         .skip(currentPage * videosPerPage)
//         .take(videosPerPage)
//         .toList();
//     displayedVideos.addAll(nextVideos);
//     currentPage++;

//     isLoadingMore = false;
//     emit(VideoLoaded(displayedVideos));
//   }

//   // void _onFilterVideos(FilterVideos event, Emitter<VideoState> emit) {
//   //   if (state is VideoLoaded) {
//   //     final filteredVideos = filterVideosUseCase(allVideos, event.filterLabel);
//   //     displayedVideos = filteredVideos.take(videosPerPage).toList();
//   //     currentPage = 1;
//   //     emit(VideoLoaded(displayedVideos, selectedFilter: event.filterLabel));
//   //   }
//   // }
// }

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:videostream/core/usecases/failer.dart';
import 'package:videostream/features/home/domain/entities/video_entity.dart';
import 'package:videostream/features/home/domain/usecase/get_videos_usecase.dart';
import 'video_event.dart';
import 'video_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
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

  // Future<void> _onFetchVideos(
  //     FetchVideosEvent event, Emitter<VideoState> emit) async {
  //   if (isFetching) return;
  //   isFetching = true;

  //   if (event.page == 0) {
  //     emit(VideoLoading());
  //     allVideos.clear();
  //   }

  //   final Either<Failure, List<VideoEntity>> result =
  //       await fetchVideos(page: event.page, filterTag: event.filterTag);

  //   result.fold(
  //     (failure) => emit(VideoError(failure.message)),
  //     (videos) {
  //       final hasMore = videos.length == 10;
  //       allVideos.addAll(videos);
  //       if (kDebugMode) {
  //         // log(allVideos.length.toString());
  //         // log(hasMore.toString());
  //       }
  //       emit(VideoLoaded(videos: allVideos, hasMoreVideos: hasMore));
  //       currentPage = event.page;
  //     },
  //   );

  //   isFetching = false;
  // }

  Future<void> _onFetchVideos(FetchVideosEvent event, Emitter<VideoState> emit) async {
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

      emit(VideoLoaded(videos: List.from(allVideos), hasMoreVideos: hasMore)); // Ensure new instance

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
