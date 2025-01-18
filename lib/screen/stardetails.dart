// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:videostream/multi_use_widget.dart';
import 'package:videostream/screen/myvideolist.dart';

class StarDetail extends StatefulWidget {
  final String collectionName;
  final String collectionImage;
  const StarDetail({
    Key? key,
    required this.collectionName,
    required this.collectionImage,
  }) : super(key: key);

  @override
  State<StarDetail> createState() => _StarDetailState();
}

class _StarDetailState extends State<StarDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collectionName),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Row(
            //   mainAxisSize: MainAxisSize.max,
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     SizedBox(
            //       height: 300,
            //       child: ClipRRect(
            //         borderRadius: BorderRadius.circular(10),
            //         child: AspectRatio(
            //           aspectRatio: 9 / 16,
            //           child: Image.file(
            //             File(widget.collectionImage),
            //             fit: BoxFit.cover,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            FutureBuilder<List<Map<String, dynamic>>>(
              // future: checkvalue(),
              future: collectionVideo(collectionName: widget.collectionName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching data'));
                }

                final data = snapshot.data! as List<dynamic>;
                List<VideoData> videos = [];
                for (var value in data) {
                  videos.add(VideoData(
                    title: value['title'],
                    link: value['videoLink'],
                    thumbnail: value['videoThumbnail'],
                    like: value['videoLike'],
                    dislike: value['videoDislike'],
                    artistName: List<String>.from(value['artistName']),
                    date: value['date'],
                    duration: value['duration'],
                    trans: value['trans'],
                    tags: List<String>.from(value['tags']),
                  ));
                }
                // for (var item in data) {
                //   videos.add(VideoData(
                //     title: item['title'] ?? '',
                //     link: item['videoLink'] ?? '',
                //     thumbnail: item['videoThumbnail'] ?? '',
                //     like: item['videoLike'] ?? 0,
                //     dislike: item['videoDislike'] ?? 0,
                //     artistName: item['artistName'],
                //     date: item['Date'] ?? '',
                //     duration: item['duration'] ?? '',
                //     trans: item['trans'] ?? '',
                //     tags: List<String>.from(item['tags'] ?? []),
                //   ));
                // }
                // data.forEach((key, value) {
                //   videos.add(
                //     VideoData(
                //       title: key,
                //       link: value['videoLink'],
                //       thumbnail: value['videoThumbnail'],
                //       like: value['videoLike'],
                //       dislike: value['videoDislike'],
                //       artistName: value['artistName'],
                //       date: value['date'],
                //       duration: value['duration'],
                //       trans: value['trans'],
                //       tags: value['tags'],
                //     ),
                //   );
                // });

                final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
                videos.sort((a, b) {
                  DateTime dateA = dateFormat.parse(a.date);
                  DateTime dateB = dateFormat.parse(b.date);
                  return dateB.compareTo(dateA);
                });

                // videos = filterVideosByLabel(videos);

                if (!snapshot.hasData || videos.isEmpty) {
                  return const Center(
                    child: SizedBox(
                      height: 120,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No Video Available!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Try again later',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  //     crossAxisCount: 2, mainAxisExtent: 230),
                  padding: const EdgeInsets.all(0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return VideoPlayerWithButton(
                      videoUrl: video.link,
                      date: video.date,
                      videoTitle: video.title,
                      duration: video.duration,
                      thumbnail: video.thumbnail,
                      artistName: video.artistName,
                      tags: video.tags,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
