part of 'random5_cubit.dart';

sealed class Random5State extends Equatable {
  const Random5State();

  @override
  List<Object> get props => [];
}

final class Random5Initial extends Random5State {}

final class Random5Loading extends Random5State {}

final class Random5Loaded extends Random5State {
  final List<VideoEntity> videos;
  const Random5Loaded(this.videos);
}
final class Random5error extends Random5State {
  final String error;
  const Random5error(this.error);
}