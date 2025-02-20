import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:videostream/features/category/data/models/category_model.dart';
import 'package:videostream/features/home/data/model/video_model.dart';

abstract class CategoryDataSource {
  Future<List<CategoryModel>> getCategoryData();
  Future<List<VideoModel>> getSpecificCategoryData(String categoryName);
  Future<void> uploadCategoryData(CategoryModel categroyData);
  Future<String> imagePicker();
}

class CategoryDataSourceImpl implements CategoryDataSource {
  var db = Db('mongodb://192.168.1.114:27017/stream');
  String imagepath = '';
  @override
  Future<List<CategoryModel>> getCategoryData() async {
    await db.open();
    final streamdb = db.collection('starData');
    // final streamdb = db.collection('testData');

    final result = await streamdb.find().toList();
    await db.close();
    return result.map((category) => CategoryModel.fromJson(category)).toList();
  }

  @override
  Future<void> uploadCategoryData(CategoryModel categoryData) async {
    try {
      var db = Db('mongodb://192.168.1.114:27017/stream');

      await db.open();
      final streamdb = db.collection('testData');

      int totalVideos = await totalVideo(categoryData.categoryName!);

      CategoryModel updatedCategory = categoryData.copyWith(
        categoryTotalVideo: totalVideos,
        categoryImagePath: imagepath.split('/').last,
      );

      await streamdb.insertOne(updatedCategory.toJson());
      db.close();
    } catch (e) {
      if (kDebugMode) {
        log(e.toString());
      }
    }
  }

  @override
  Future<String> imagePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      String? filePath = result.files.single.path;

      if (filePath != null) {
        imagepath = filePath;
        return filePath;
      }
    }
    return 'null'; // Return null to indicate no file was selected
  }

  Future<int> totalVideo(String collectionName) async {
    await db.open();
    final streamdb = db.collection('allVideoData');
    if (collectionName == 'dart') {
      final result = await streamdb.count({
        {
          'man': {
            r'$regex': true,
          }
        },
      });
      await db.close();
      return result;
    } else {
      final result = await streamdb.count({
        r'$or': [
          {
            'title': {
              r'$regex': collectionName,
              r'$options': "i",
            }
          },
          {
            'artistName': {
              r'$regex': collectionName,
              r'$options': "i",
            }
          },
          {
            'tags': {
              r'$regex': collectionName,
              r'$options': "i",
            }
          },
        ]
      });
      await db.close();
      return result;
    }
  }

  @override
  Future<List<VideoModel>> getSpecificCategoryData(
      String collectionName) async {
    try {
      await db.open();

      final streamdb = db.collection('allVideoData');
      if (collectionName == 'shemale') {
        final result = await streamdb.find({
          {
            'trans': {
              true,
            }
          }
        }).toList();

        return result.map((video) => VideoModel.fromJson(video)).toList();
      } else {
        final result = await streamdb.find({
          r'$or': [
            {
              'title': {
                r'$regex': collectionName,
                r'$options': 'i',
              }
            },
            {
              'artistName': {
                r'$regex': collectionName,
                r'$options': 'i',
              }
            },
            {
              'tags': {
                r'$regex': collectionName,
                r'$options': 'i',
              }
            },
          ]
        }).toList();

        await db.close();
        return result.map((video) => VideoModel.fromJson(video)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error in collectionVideo: $e');
      }
      throw Exception(e.toString());
    }
  }
}
