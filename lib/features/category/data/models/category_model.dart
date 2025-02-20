import 'package:videostream/features/category/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    super.categoryName,
    super.categroyImagePath,
    super.categoryTotalVideo,
  });
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryName: json['title'] as String?,
      categroyImagePath: json['starLink'] as String?,
      categoryTotalVideo: json['totalVideo'] as int?,
    );
  }
  CategoryModel copyWith({
    String? categoryImagePath,
    int? categoryTotalVideo,
  }) {
    return CategoryModel(
      categoryName: categoryName,
      categroyImagePath: categoryImagePath ?? categroyImagePath,
      categoryTotalVideo: categoryTotalVideo ?? this.categoryTotalVideo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': categoryName,
      'starLink': 'http://192.168.1.114/videos/star/$categroyImagePath',
      'totalVideo': categoryTotalVideo,
    };
  }
}
