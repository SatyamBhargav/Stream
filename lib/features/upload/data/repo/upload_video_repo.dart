
import 'package:videostream/features/upload/data/data_source/upload_service.dart';
import 'package:videostream/features/upload/data/models/videos.dart';
import 'package:videostream/features/upload/domain/entities/videos.dart';
import 'package:videostream/features/upload/domain/repos/video_repo.dart';

class UploadRepositoryImpl implements UploadRepository {
  final UploadServiceSource uploadDataSource;
  UploadRepositoryImpl(this.uploadDataSource);

  @override
  Future<void> uploadData(UploadDataEntities uploadDataValue) async {
    try {
      final uploadDataModel = UploadDataModel(
        artistName: uploadDataValue.artistName,
        title: uploadDataValue.title,
        duration: uploadDataValue.duration,
        like: uploadDataValue.like,
        tags: uploadDataValue.tags,
        thumbnail: uploadDataValue.thumbnail,
        link: uploadDataValue.link,
        trans: uploadDataValue.trans,
        date: uploadDataValue.date,
        dislike: uploadDataValue.dislike,
      );
      await uploadDataSource.uploadData(uploadDataModel);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // @override
  // Future<void> uploadFile(UploadFileEntities uploadFileValue,bool thumbnail) async {
  //   try {
  //     final uploadFileModel = UploadFileModel(
  //       fileName: uploadFileValue.fileName,
  //     );
  //     await uploadDataSource.uploadFile(uploadFileModel,thumbnail);
  //   } catch (e) {
  //     throw Exception(e.toString());
  //   }
  // }
}
