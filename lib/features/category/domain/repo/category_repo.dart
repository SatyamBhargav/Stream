import 'package:videostream/features/category/domain/entities/category_entity.dart';
import 'package:videostream/features/home/domain/entities/video_entity.dart';

abstract class CategoryRepo {
  Future<void> uploadCategoryData(CategoryEntity categoryData);
  Future<List<CategoryEntity>> receiveCategoryData();
  Future<List<VideoEntity>> receiveSpecificCategoryData(String categoryName);
  Future<String> selectCategoryImage();
}
