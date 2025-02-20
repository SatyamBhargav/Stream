
import 'package:mongo_dart/mongo_dart.dart';

import 'package:videostream/features/upload/data/models/videos.dart';

abstract class UploadServiceSource {
  Future<void> uploadData(UploadDataModel upload);
  // Future<void> uploadFile(UploadFileModel upload,bool thumbnail);
}

class UploadServiceSourceImpl implements UploadServiceSource {
  @override
  Future<void> uploadData(UploadDataModel upload) async {
    try {
      var db = Db('mongodb://192.168.1.114:27017/stream');
      await db.open();
      final streamdb = db.collection('allVideoData');
      streamdb.insertOne(upload.toJson());
      db.close();
    } catch (e) {
      throw Exception(e.toString());
    }
  }


}
