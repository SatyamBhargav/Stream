part of 'upload_category_data_cubit.dart';

sealed class UploadCategoryDataState extends Equatable {
  const UploadCategoryDataState();

  @override
  List<Object> get props => [];
}

final class UploadCategoryDataInitial extends UploadCategoryDataState {}

final class UploadCategoryImageDataLoading extends UploadCategoryDataState {}

final class UploadCategoryImageDataLoaded extends UploadCategoryDataState {
  final String imageData;
  const UploadCategoryImageDataLoaded(this.imageData);
}

// ignore: must_be_immutable
final class UploadCategoryImageDataError extends UploadCategoryDataState {
  String error;
  UploadCategoryImageDataError(this.error);
}

final class UploadCategoryDataLoading extends UploadCategoryDataState {}

final class UploadCategoryDataLoaded extends UploadCategoryDataState {}

// ignore: must_be_immutable
final class UploadCategoryDataError extends UploadCategoryDataState {
  String error;
  UploadCategoryDataError(this.error);
}

class UploadCategoryImage extends UploadCategoryDataState {
  final File uploadFileEntities;
  final bool thumbnail;
  const UploadCategoryImage(this.uploadFileEntities, this.thumbnail);
}
