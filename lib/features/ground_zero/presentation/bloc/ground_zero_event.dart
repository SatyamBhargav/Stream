part of 'ground_zero_bloc.dart';

sealed class GroundZeroEvent extends Equatable {
  const GroundZeroEvent();

  @override
  List<Object> get props => [];
}

class FetchVideo extends GroundZeroEvent {}
