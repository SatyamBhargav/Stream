import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:videostream/screen/upload.dart';

Widget formatedText({
  required String text,
  required String fontFamily,
  double? size = 17,
  FontWeight? fontweight = FontWeight.w400,
  Color? color,
  TextDecoration? decoration,
}) {
  return Text(
    text,
    // overflow: TextOverflow.ellipsis,
    // maxLines: 1,
    style: GoogleFonts.getFont(
      fontFamily,
      color: color,
      fontSize: size,
      fontWeight: fontweight,
      decoration: decoration,
    ),
  );
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}

String timeAgo(String dateString) {
  DateFormat format = DateFormat('dd/MM/yyyy HH:mm');
  DateTime inputDate = format.parse(dateString);
  DateTime currentDate = DateTime.now();

  Duration difference = currentDate.difference(inputDate);

  if (difference.inDays >= 30) {
    int months = (difference.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  } else if (difference.inDays >= 1) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inHours >= 1) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inMinutes >= 1) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return 'just now';
  }
}

// Future<Map<String, dynamic>> checkvalue() async {
//   try {
//     final response = await http.get(Uri.parse(
//         'http://192.168.1.114:80/videos/video_json/videostream.json'));

//     // 'http://192.168.1.114/videos/video_json/testjson.json'));
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> videoLinks = jsonDecode(response.body);
//       return videoLinks;
//     } else {
//       log('Failed to load videos. Status code: ${response.statusCode}');
//       return {};
//     }
//   } catch (e) {
//     log('Error fetching videos: $e');
//     return {};
//   }
// }

Future<List<Map<String, dynamic>>> videoData(
    {required String databaseName}) async {
  var db = Db('mongodb://192.168.1.114:27017/stream');
  await db.open();
  final streamdb = db.collection(databaseName);
  // final streamdb = db.collection('comments');

  final result = await streamdb.find().toList();
  await db.close();
  return result;
}

// basicquery1() async {
//   var db = Db('mongodb://192.168.1.114:27017/stream');
//   await db.open();
//   final streamdb = db.collection('testVideoData');

//   streamdb.insertOne({
//     "videoLike": 5,
//     "videoDislike": 2,
//     "artistName": "artistName",
//     "date": "date",
//     "duration": "videoDuration",
//     "trans": false,
//     "tags": "tags"
//   });
//   await db.close();
//   log('done');
// }

class VideoData {
  final String title;
  final String link;
  final String thumbnail;
  final int like;
  final int dislike;
  final List artistName;
  final String date;
  final String duration;
  final bool trans;
  final List tags;

  VideoData({
    required this.title,
    required this.link,
    required this.thumbnail,
    required this.like,
    required this.dislike,
    required this.artistName,
    required this.date,
    required this.duration,
    required this.trans,
    required this.tags,
  });

  bool get isValidVideoLink {
    return link.startsWith('http://') && link.endsWith('.mp4');
  }
}

class StarData {
  final String title;
  final String link;
  final int totalVideos;

  StarData({
    required this.title,
    required this.link,
    required this.totalVideos,
  });

  bool get isValidVideoLink {
    return link.startsWith('http://') && link.endsWith('.mp4');
  }
}

Future<List<Map<String, dynamic>>> collectionVideo(
    {required String collectionName}) async {
  log('Function called: collectionVideo');

  var db = Db('mongodb://192.168.1.114:27017/stream');

  try {
    await db.open();
    log('Database connection opened.');

    final streamdb = db.collection('allVideoData');
    if (collectionName == 'shemale') {
      final result = await streamdb.find({
        {
          'trans': {
            true,
          }
        }
      }).toList();

      log('Query executed successfully.');
      return result;
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

      log('Query executed successfully.');
      return result;
    }
  } catch (e) {
    log('Error in collectionVideo: $e');
    return [];
  } finally {
    await db.close();
    log('Database connection closed.');
  }
}

Future<void> uploadImage(File videoFile, String folderName) async {
  final uri = Uri.parse('http://192.168.1.114:5000/$folderName');

  final request = http.MultipartRequest('POST', uri)
    ..files.add(await http.MultipartFile.fromPath(
      'file',
      videoFile.path,
      filename: basename(videoFile.path),
    ));

  try {
    final response = await request.send();

    if (response.statusCode == 200) {
      if (kDebugMode) {
        log('Thumbnail uploaded successfully');
      }
    } else {
      if (kDebugMode) {
        log('Failed to upload video. Status code: ${response.statusCode}\n${response.request}');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      log('Error uploading video: $e');
    }
  }
}

Future<void> updateVideoJson(
    Map<String, dynamic> newVideoData, String databaseName) async {
  var db = Db('mongodb://192.168.1.114:27017/stream');
  await db.open();
  final streamdb = db.collection(databaseName);
  streamdb.insertOne(newVideoData);
  db.close();
}

Future<void> selectVideo(BuildContext context) async {
  File? _videoFile;

  // Open the file picker to select a video file
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null && result.files.isNotEmpty) {
    // Get the path of the selected video file
    String? filePath = result.files.single.path;

    if (filePath != null) {
      _videoFile = File(filePath);

      // Generate a thumbnail from the selected video
      await _generateThumbnail(_videoFile, context);
    } else {
      // Handle the case where the file path is null
      if (kDebugMode) {
        print("No valid file path found.");
      }
    }
  } else {
    // Handle the case where no file was selected
    if (kDebugMode) {
      print("No file selected.");
    }
  }
}

Future<void> _generateThumbnail(File? _videoFile, BuildContext context) async {
  String? videoDuration;

  // Create a VideoPlayerController to get the video's dimensions
  final controller = VideoPlayerController.file(_videoFile!);
  await controller.initialize();
  final videoLength = controller.value.duration;
  videoDuration = formatDuration(videoLength);
  final videoWidth = controller.value.size.width;
  final videoHeight = controller.value.size.height;

  // Set the thumbnail size based on the video's aspect ratio
  int maxWidth, maxHeight;
  if (videoWidth > videoHeight) {
    // Landscape
    maxWidth = 428; // You can adjust this value as needed
    maxHeight = (maxWidth * videoHeight ~/ videoWidth); // Maintain aspect ratio
  } else {
    // Portrait
    maxHeight = 228; // You can adjust this value as needed
    maxWidth = (maxHeight * videoWidth ~/ videoHeight); // Maintain aspect ratio
  }

  final thumbnailPath = await VideoThumbnail.thumbnailFile(
    video: _videoFile!.path,
    thumbnailPath: (await getTemporaryDirectory()).path,
    imageFormat: ImageFormat.JPEG,
    maxWidth: maxWidth,
    maxHeight: maxHeight, // Use the calculated max height
    quality: 75,
  );
  // await Future.delayed(const Duration(seconds: 1));
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Upload(
                thumbnail: Image.file(
                  File(thumbnailPath.path),
                ),
                thumbnailPath: thumbnailPath.path,
                videoDuration: videoDuration,
                videoFile: _videoFile,
              )));

  // setState(() {
  //   _thumbnail = );
  //   _thumbnailPath = ;
  // });

  // Dispose the controller after use
  controller.dispose();
}

Future<bool> checkScriptStatus() async {
  try {
    Dio dio = Dio();
    final response = await dio.get('http://192.168.1.114:5000/status');

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    log('not running');
    return false;
  }
}
