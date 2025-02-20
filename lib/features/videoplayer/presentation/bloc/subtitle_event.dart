part of 'subtitle_bloc.dart';

sealed class SubtitleEvent extends Equatable {
  const SubtitleEvent();

  @override
  List<Object> get props => [];
}

class FetchSubtitle extends SubtitleEvent {}

class UpdateSubtitle extends SubtitleEvent {
  final int currentTime;
  const UpdateSubtitle(this.currentTime);

  @override
  List<Object> get props => [currentTime];
}
