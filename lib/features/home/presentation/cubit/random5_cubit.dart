import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:videostream/features/home/domain/entities/video_entity.dart';
import 'package:videostream/features/home/domain/usecase/get_random_video.dart';

part 'random5_state.dart';

class Random5Cubit extends Cubit<Random5State> {
  final GetRandomVideosHomeUseCase randomVideosHomeUseCase;
  Random5Cubit(this.randomVideosHomeUseCase) : super(Random5Initial());
  void onFetchRandomVideo() async {
    emit(Random5Loading());
    try {
      final categoryVideoData = await randomVideosHomeUseCase.call();
      emit(Random5Loaded(categoryVideoData));
    } catch (e) {
      emit(Random5error(e.toString()));
    }
  }
}
