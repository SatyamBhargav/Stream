import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:videostream/features/ground_zero/domain/usecase/cheupdate_usecase.dart';

part 'update_app_state.dart';

class UpdateAppCubit extends Cubit<UpdateAppState> {
  final CheupdateUsecase updateStatus;
  UpdateAppCubit(this.updateStatus) : super(UpdateAppInitial());
  Future<void> onUploadStatus() async {
    // emit(UploadStatusLoading());
    try {
      final uploadStatusData = await updateStatus.call();
      emit(UpdateAppLoded(uploadStatusData[0],uploadStatusData[1],uploadStatusData[2]));
    } catch (e) {
      emit(UpdateAppError(e.toString()));
    }
  }
}
