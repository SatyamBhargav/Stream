part of 'ground_zero_bloc.dart';

sealed class GroundZeroState extends Equatable {
  const GroundZeroState();

  @override
  List<Object> get props => [];
}

final class GroundZeroInitial extends GroundZeroState {}

final class GroundZeroLoading extends GroundZeroState {}

final class GroundZeroLoaded extends GroundZeroState {
  final VidoePickerEntity video;

  const GroundZeroLoaded(this.video);

  @override
  List<Object> get props => [video];
}

final class GroundZeroError extends GroundZeroState {
  final String message;

  const GroundZeroError(this.message);

  @override
  List<Object> get props => [message];
}
