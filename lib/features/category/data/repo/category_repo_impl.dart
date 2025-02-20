import 'package:videostream/features/category/data/data_source/category_service.dart';
import 'package:videostream/features/category/data/models/category_model.dart';
import 'package:videostream/features/category/domain/entities/category_entity.dart';
import 'package:videostream/features/category/domain/repo/category_repo.dart';
import 'package:videostream/features/home/data/model/video_model.dart';
import 'package:videostream/features/home/domain/entities/video_entity.dart';

class CategoryRepoImpl implements CategoryRepo {
  final CategoryDataSource remoteDataSource;
  CategoryRepoImpl(this.remoteDataSource);

  @override
  Future<List<CategoryEntity>> receiveCategoryData() async {
    try {
      List<CategoryModel> videos = await remoteDataSource.getCategoryData();
      return videos;
    } catch (e) {
      throw Exception("Failed to fetch category data");
    }
  }

  @override
  Future<void> uploadCategoryData(CategoryEntity categoryData) async {
    try {
      await remoteDataSource.uploadCategoryData(CategoryModel(
        categoryName: categoryData.categoryName,
      ));
    } catch (e) {
      throw Exception("Failed to upload category data");
    }
  }

  @override
  Future<List<VideoEntity>> receiveSpecificCategoryData(
      String categoryName) async {
    try {
      List<VideoModel> videos =
          await remoteDataSource.getSpecificCategoryData(categoryName);
      return videos;
    } catch (e) {
      throw Exception("Failed to fetch specific category data");
    }
  }

  @override
  Future<String> selectCategoryImage() async {
    try {
      String categoryImagePath = await remoteDataSource.imagePicker();
      return categoryImagePath;
    } catch (e) {
      throw Exception("Failed to fetch category image");
    }
  }
}
