part of 'download_update_cubit.dart';

sealed class DownloadUpdateState extends Equatable {
  const DownloadUpdateState();

  @override
  List<Object> get props => [];
}

final class DownloadUpdateInitial extends DownloadUpdateState {}

class AppUpdateInitial extends DownloadUpdateState {}

class AppUpdateInProgress extends DownloadUpdateState {
  final int progress;
  const AppUpdateInProgress(this.progress);
  @override
  List<Object> get props => [progress];
}

class AppUpdateSuccess extends DownloadUpdateState {}

class AppUpdateFailure extends DownloadUpdateState {
  final String errorMessage;
  const AppUpdateFailure(this.errorMessage);
}
