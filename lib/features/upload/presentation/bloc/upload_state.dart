part of 'upload_bloc.dart';

sealed class UploadState extends Equatable {
  const UploadState();
  
  @override
  List<Object> get props => [];
}

final class UploadInitial extends UploadState {}

final class UploadLoading extends UploadState {}

final class UploadSuccess extends UploadState {}

final class UploadError extends UploadState {
  final String message;

  const UploadError(this.message);

  @override
  List<Object> get props => [message];
}