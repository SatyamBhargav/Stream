
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:videostream/features/ground_zero/domain/usecase/download_update_usecase.dart';

part 'download_update_state.dart';

class DownloadUpdateCubit extends Cubit<DownloadUpdateState> {
  final DownloadUpdateUsecase downloadUpdateUsecase;

  DownloadUpdateCubit(this.downloadUpdateUsecase)
      : super(DownloadUpdateInitial());

  Future<void> updateApp() async {
    try {
      emit(const AppUpdateInProgress(0));

      await downloadUpdateUsecase.call((progress) {
        emit(AppUpdateInProgress(progress)); // Update real-time progress
      });

      emit(AppUpdateSuccess());
    } catch (e) {
      emit(AppUpdateFailure(e.toString()));
    }
  }
}
