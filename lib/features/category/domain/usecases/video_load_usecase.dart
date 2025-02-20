import 'package:intl/intl.dart';
import 'package:videostream/features/category/domain/repo/category_repo.dart';
import 'package:videostream/features/home/domain/entities/video_entity.dart';

class GetCategoryVideoUseCase {
  final CategoryRepo repository;

  GetCategoryVideoUseCase(this.repository);

  Future<List<VideoEntity>> call(String categoryName) async {
    final videos = await repository.receiveSpecificCategoryData(categoryName);

    // Sort videos by date (latest first)
    // final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    // videos.sort((a, b) {
    //   DateTime dateA = dateFormat.parse(a.date!);
    //   DateTime dateB = dateFormat.parse(b.date!);
    //   return dateB.compareTo(dateA);
    // });

    return videos;
  }
}
