part of 'upload_status_cubit.dart';

sealed class UploadStatusState extends Equatable {
  const UploadStatusState();

  @override
  List<Object> get props => [];
}

final class UploadStatusInitial extends UploadStatusState {}

final class UploadStatusLoading extends UploadStatusState {}

final class UploadStatusLoaded extends UploadStatusState {
  final bool uploadstaus;
  const UploadStatusLoaded(this.uploadstaus);
  @override
  List<Object> get props => [];
}

final class UploadStatusError extends UploadStatusState{
  final String error;
  const UploadStatusError(this.error);
}