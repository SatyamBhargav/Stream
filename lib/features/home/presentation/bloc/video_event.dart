// import 'package:equatable/equatable.dart';

// abstract class VideoEvent extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class FetchVideos extends VideoEvent {}

// class LoadMoreVideos extends VideoEvent {}

// class FilterVideos extends VideoEvent {
//   final String filterLabel;
  
//   FilterVideos(this.filterLabel);
// }

import 'package:equatable/equatable.dart';

abstract class VideoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Fetch videos when the screen loads or user scrolls down
class FetchVideosEvent extends VideoEvent {
  final int page;
  final String? filterTag;

  FetchVideosEvent({required this.page, this.filterTag});

  @override
  List<Object?> get props => [page, filterTag];
}

// Filter videos based on a selected tag
class FilterVideosEvent extends VideoEvent {
  final String? filterTag;

  FilterVideosEvent(this.filterTag);

  @override
  List<Object?> get props => [filterTag];
}
