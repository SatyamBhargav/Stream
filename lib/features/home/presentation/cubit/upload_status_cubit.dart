import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:videostream/features/home/domain/usecase/upload_status_usecase.dart';

part 'upload_status_state.dart';

class UploadStatusCubit extends Cubit<UploadStatusState> {
  final UploadStatusUsecase uploadstatus;
  StreamSubscription? _statusSubscription;
  bool _isPaused = false;

  UploadStatusCubit(this.uploadstatus) : super(UploadStatusInitial()) {
    _startAutoCheck();
  }

  void _startAutoCheck() {
    _statusSubscription?.cancel(); // Cancel any previous subscription
    _statusSubscription =
        Stream.periodic(const Duration(seconds: 5)).listen((_) async {
      if (!_isPaused) {
        await onUploadStatus();
      }
    });
  }

  Future<void> onUploadStatus() async {
    emit(UploadStatusLoading());
    try {
      final uploadStatusData = await uploadstatus.call();
      emit(UploadStatusLoaded(uploadStatusData));
    } catch (e) {
      emit(UploadStatusError(e.toString()));
      _pauseAutoCheck();
    }
  }

  void _pauseAutoCheck() {
    _isPaused = true;
    Future.delayed(const Duration(minutes: 1), () {
      if (!isClosed) {
        _isPaused = false;
      }
    });
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    return super.close();
  }
}
