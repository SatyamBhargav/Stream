part of 'update_app_cubit.dart';

sealed class UpdateAppState extends Equatable {
  const UpdateAppState();

  @override
  List<Object> get props => [];
}

final class UpdateAppInitial extends UpdateAppState {}

final class UpdateAppLoded extends UpdateAppState {
  final bool appStatus;
  final String latestVersion;
  final String currentVersion;
  const UpdateAppLoded(this.appStatus, this.latestVersion, this.currentVersion);
}

final class UpdateAppError extends UpdateAppState {
  final String error;
  const UpdateAppError(this.error);
}
