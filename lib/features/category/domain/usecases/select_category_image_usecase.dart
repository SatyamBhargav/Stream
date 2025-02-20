import 'package:videostream/features/category/domain/repo/category_repo.dart';

class UpdateCategoryImageUseCase {
  final CategoryRepo categoryRepo;
  UpdateCategoryImageUseCase(this.categoryRepo);
  Future<String> call() async {
    return await categoryRepo.selectCategoryImage();
  }
}
