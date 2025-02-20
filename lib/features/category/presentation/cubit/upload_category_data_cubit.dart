import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:videostream/core/usecases/upload_file_usecase.dart';
import 'package:videostream/features/category/domain/entities/category_entity.dart';
import 'package:videostream/features/category/domain/usecases/category_upload_usecase.dart';
import 'package:videostream/features/category/domain/usecases/select_category_image_usecase.dart';

part 'upload_category_data_state.dart';

class UploadCategoryDataCubit extends Cubit<UploadCategoryDataState> {
  final CategoryUploadUsecase uploadUsecase;
  final UpdateCategoryImageUseCase uploadImage;
  final UploadFileUseCase uploadFileUseCase;
  UploadCategoryDataCubit(
      this.uploadUsecase, this.uploadImage, this.uploadFileUseCase)
      : super(UploadCategoryDataInitial());
  String imageData = '';
  void onUploadCategoryData(String categoryName) {
    emit(UploadCategoryDataLoading());
    try {
      uploadUsecase.call(CategoryEntity(categoryName: categoryName));
      emit(UploadCategoryDataLoaded());
    } catch (e) {
      emit(UploadCategoryDataError(e.toString()));
    }
  }

  void onUpdateCategoryImage() async {
    emit(UploadCategoryImageDataLoading());
    try {
      imageData = await uploadImage.call();
      emit(UploadCategoryImageDataLoaded(imageData));
    } catch (e) {
      emit(UploadCategoryImageDataError(e.toString()));
    }
  }

  void onUploadCategoryImage(bool thumbnail, bool categoryImage) async {
    try {
      await uploadFileUseCase(File(imageData), thumbnail,categoryImage);
    } catch (e) {
      emit(UploadCategoryImageDataError(e.toString()));
    }
  }
}
