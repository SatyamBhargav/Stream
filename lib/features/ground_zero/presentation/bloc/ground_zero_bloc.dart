import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:videostream/features/ground_zero/domain/entities/zero_entity.dart';
import 'package:videostream/features/ground_zero/domain/usecase/zero_usecase.dart';

part 'ground_zero_event.dart';
part 'ground_zero_state.dart';

class GroundZeroBloc extends Bloc<GroundZeroEvent, GroundZeroState> {
  final GetZeroUsecase getZeroUsecase;
  GroundZeroBloc(this.getZeroUsecase) : super(GroundZeroInitial()) {
    on<GroundZeroEvent>(_onfetchVideo);
  }

  Future<void> _onfetchVideo(
      GroundZeroEvent event, Emitter<GroundZeroState> emit) async {
    emit(GroundZeroLoading());
    try {
      final video = await getZeroUsecase();
      emit(GroundZeroLoaded(video));
    } catch (e) {
      emit(GroundZeroError(e.toString()));
    }
  }
}
