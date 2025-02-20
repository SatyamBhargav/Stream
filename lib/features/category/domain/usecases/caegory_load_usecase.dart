import 'package:videostream/features/category/domain/entities/category_entity.dart';
import 'package:videostream/features/category/domain/repo/category_repo.dart';

class CaegoryLoadDataUsecase {
  final CategoryRepo categoryRepo;
  CaegoryLoadDataUsecase(this.categoryRepo);
  Future<List<CategoryEntity>> call() async {
    return await categoryRepo.receiveCategoryData();
  }
}
