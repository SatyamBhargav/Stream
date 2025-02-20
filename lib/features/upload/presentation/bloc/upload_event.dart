part of 'upload_bloc.dart';

sealed class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object> get props => [];
}

final class UploadDataEvent extends UploadEvent {
  final UploadDataEntities uploadDataEntities;
  const UploadDataEvent(this.uploadDataEntities);

  @override
  List<Object> get props => [uploadDataEntities];
}

final class UploadFileEvent extends UploadEvent {
  final File uploadFileEntities;
  final bool thumbnail; final bool categoryImage;

  const UploadFileEvent(this.uploadFileEntities, this.thumbnail,this.categoryImage);

  @override
  List<Object> get props => [uploadFileEntities];
}
