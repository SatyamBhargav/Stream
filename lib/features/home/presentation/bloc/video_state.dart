import 'package:equatable/equatable.dart';
import 'package:videostream/features/home/domain/entities/video_entity.dart';


abstract class VideoState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state
class VideoInitial extends VideoState {}

// Loading state
class VideoLoading extends VideoState {}

// Videos loaded successfully
class VideoLoaded extends VideoState {
  final List<VideoEntity> videos;
  final bool hasMoreVideos;

  VideoLoaded({required this.videos, required this.hasMoreVideos});

  @override
  List<Object?> get props => [videos, hasMoreVideos];
}

// Error state
class VideoError extends VideoState {
  final String message;

  VideoError(this.message);

  @override
  List<Object?> get props => [message];
}
