import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:videostream/features/upload/domain/entities/videos.dart';
import 'package:videostream/features/upload/domain/usecases/upload_data.dart';
import 'package:videostream/core/usecases/upload_file_usecase.dart';

part 'upload_event.dart';
part 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final UploadFileUseCase uploadFileUseCase;
  final UploadVideoUseCase uploadVideoUseCase;
  UploadBloc(this.uploadFileUseCase, this.uploadVideoUseCase)
      : super(UploadInitial()) {
    on<UploadEvent>(_onUpload);
  }
  void _onUpload(UploadEvent event, Emitter<UploadState> emit) async {
    try {
      emit(UploadLoading());
      if (event is UploadDataEvent) {
        await uploadVideoUseCase(event.uploadDataEntities);
      } else if (event is UploadFileEvent) {
        await uploadFileUseCase(event.uploadFileEntities, event.thumbnail,event.categoryImage);
      }
      emit(UploadSuccess());
    } catch (e) {
      emit(UploadError(e.toString()));
    }
  }
}
