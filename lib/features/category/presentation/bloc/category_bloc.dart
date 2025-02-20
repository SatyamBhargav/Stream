
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:videostream/features/category/domain/usecases/category_upload_usecase.dart';

import 'package:videostream/features/category/presentation/bloc/category_event.dart';
import 'package:videostream/features/category/presentation/bloc/category_state.dart';
import 'package:videostream/features/category/domain/usecases/caegory_load_usecase.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryUploadUsecase categoryUploadUsecase;
  final CaegoryLoadDataUsecase categoryLoadUsecase;

  CategoryBloc(this.categoryUploadUsecase, this.categoryLoadUsecase,
     )
      : super(CategoryInitial()) {
    on<FetchCategoryData>(_onFetchCategory);

  }

  void _onFetchCategory(
      FetchCategoryData event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final categoryData = await categoryLoadUsecase();
      emit(CategoryLoaded(categoryData));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }


}
