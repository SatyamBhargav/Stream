import 'dart:math';
import 'package:dio/dio.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:videostream/features/home/data/model/video_model.dart';

abstract class VideoRemoteDataSource {
  Future<List<VideoModel>> fetchVideos(int page, String? filterTag);
  Future<List<VideoModel>> fetchRandomVideo();
  Future<bool> uploadStatus();
}

class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  @override
  Future<List<VideoModel>> fetchVideos(int page, String? filterTag) async {
    try {
      var db = Db('mongodb://192.168.1.114:27017/stream');

      await db.open();
      final streamdb = db.collection('allVideoData');
      // final streamdb = db.collection('testVideoData');

      // final response = await streamdb.find().toList();
      if (filterTag == null) {
        final response = await streamdb
            .find(where
                .sortBy('date', descending: true)
                .limit(10)
                .skip(page * 10))
            .toList();
        await db.close();

        return response.map((video) => VideoModel.fromJson(video)).toList();
      } else {
        final response = await streamdb
            .find(where
                .limit(10)
                .skip(page * 10)
                .eq('tags', {'\$regex': filterTag, '\$options': 'i'}))
            .toList();
        await db.close();

        return response.map((video) => VideoModel.fromJson(video)).toList();
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<bool> uploadStatus() async {
    try {
      Dio dio = Dio();
      final response = await dio.get('http://192.168.1.114:5000/status');

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<VideoModel>> fetchRandomVideo() async {
    try {
      var db = Db('mongodb://192.168.1.114:27017/stream');
      await db.open();

      final streamdb = db.collection('allVideoData');

      // Fetch all documents (not ideal for large datasets)
      final List<Map<String, dynamic>> response =
          await streamdb.find().toList();

      await db.close();

      // Shuffle the list and take 5 random items
      response.shuffle(Random());
      List<Map<String, dynamic>> randomVideos = response.take(5).toList();
      return randomVideos.map((video) => VideoModel.fromJson(video)).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
