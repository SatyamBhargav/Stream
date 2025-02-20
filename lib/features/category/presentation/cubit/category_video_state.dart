part of 'category_video_cubit.dart';

sealed class CategoryVideoState extends Equatable {
  const CategoryVideoState();

  @override
  List<Object> get props => [];
}

final class CategoryVideoInitial extends CategoryVideoState {}
final class CategoryVideoLoding extends CategoryVideoState {}

final class CategoryVideoLoaded extends CategoryVideoState {
  final List<VideoEntity> categoriesVideo;

  const CategoryVideoLoaded(this.categoriesVideo);

  @override
  List<Object> get props => [categoriesVideo];
}

final class CategoryVideoError extends CategoryVideoState {
  final String message;

  const CategoryVideoError(this.message);

  @override
  List<Object> get props => [message];
}
