import 'package:videostream/features/category/domain/repo/category_repo.dart';
import 'package:videostream/features/home/domain/entities/video_entity.dart';

class GetCategoryVideoUseCase {
  final CategoryRepo repository;

  GetCategoryVideoUseCase(this.repository);

  Future<List<VideoEntity>> call(String categoryName) async {
    final videos = await repository.receiveSpecificCategoryData(categoryName);
    return videos;
  }
}
