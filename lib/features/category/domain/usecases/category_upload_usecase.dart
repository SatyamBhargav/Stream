import 'package:videostream/features/category/domain/entities/category_entity.dart';
import 'package:videostream/features/category/domain/repo/category_repo.dart';

class CategoryUploadUsecase {
  final CategoryRepo _categoryRepo;
  CategoryUploadUsecase(this._categoryRepo);
  Future<void> call(CategoryEntity uploadData) async {
    return await _categoryRepo.uploadCategoryData(uploadData);
  }
}
