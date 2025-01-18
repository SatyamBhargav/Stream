import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';

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

Future<List<Map<String, dynamic>>> videoData() async {
  var db = Db('mongodb://192.168.1.114:27017/stream');
  await db.open();
  // final streamdb = db.collection('allVideoData');
  final streamdb = db.collection('comments');

  final result = await streamdb.find().toList();
  await db.close();
  return result;
}

basicquery1() async {
  var db = Db('mongodb://192.168.1.114:27017/stream');
  await db.open();
  final streamdb = db.collection('testVideoData');

  streamdb.insertOne({
    "videoLike": 5,
    "videoDislike": 2,
    "artistName": "artistName",
    "date": "date",
    "duration": "videoDuration",
    "trans": false,
    "tags": "tags"
  });
  await db.close();
  log('done');
}

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
