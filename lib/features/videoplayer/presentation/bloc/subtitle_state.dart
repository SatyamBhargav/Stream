part of 'subtitle_bloc.dart';

abstract class SubtitleState extends Equatable {
  const SubtitleState();

  @override
  List<Object?> get props => [];
}

class SubtitleInitial extends SubtitleState {}


class SubtitleLoaded extends SubtitleState {
  final List<Map<String, dynamic>> subtitles;
  final String? currentSubtitle;

  const SubtitleLoaded(this.subtitles, {this.currentSubtitle});

  @override
  List<Object?> get props => [subtitles, currentSubtitle];
}

class SubtitleEmpty extends SubtitleState {}

class SubtitleError extends SubtitleState {
  final String message;
  const SubtitleError(this.message);

  @override
  List<Object> get props => [message];
}
