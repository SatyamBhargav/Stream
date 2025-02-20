import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:videostream/features/category/domain/usecases/video_load_usecase.dart';
import 'package:videostream/features/home/domain/entities/video_entity.dart';

part 'category_video_state.dart';

class CategoryVideoCubit extends Cubit<CategoryVideoState> {
  final GetCategoryVideoUseCase categaryVideoUsecase;

  CategoryVideoCubit(this.categaryVideoUsecase) : super(CategoryVideoInitial());

  void onFetchCategoryVideo(String categoryName) async {
    emit(CategoryVideoLoding());
    try {
      final categoryVideoData = await categaryVideoUsecase(categoryName);
      emit(CategoryVideoLoaded(categoryVideoData));
    } catch (e) {
      emit(CategoryVideoError(e.toString()));
    }
  }
}
