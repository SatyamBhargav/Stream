// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:videostream/multi_use_widget.dart';
import 'package:videostream/star.dart';
import 'package:videostream/upload.dart';
import 'package:videostream/videoscreen.dart';

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

class MyVideoList extends StatefulWidget {
  const MyVideoList({
    super.key,
  });

  @override
  _MyVideoListState createState() => _MyVideoListState();
}

class _MyVideoListState extends State<MyVideoList> {
  String currentLable = 'All';

  List<VideoData> filterVideosByLabel(List<VideoData> videos) {
    if (currentLable == 'All') return videos;
    return videos.where((video) {
      return video.tags
          .any((tag) => tag.toLowerCase() == currentLable.toLowerCase());
    }).toList();
  }

  Widget buildCategoryChip(String label, double width) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentLable = label;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          decoration: BoxDecoration(
            color:
                currentLable == label ? Colors.white : const Color(0xff282828),
            border: Border.all(
                color: currentLable == label
                    ? Colors.white
                    : const Color(0xff282828)),
            borderRadius: BorderRadius.circular(7),
          ),
          height: 35,
          width: width,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: currentLable == label ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                title: const Text(
                  'Stream',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/logo.jpeg',
                      height: 40,
                    )),
                trailing: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ),
              const SizedBox(height: 10),
              const Divider(
                indent: 10,
                endIndent: 10,
              ),
              ListTile(
                leading: const Icon(Icons.video_collection_rounded),
                title: const Text('Collection'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Star(),
                      ));
                },
              ),
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xff141218),
            centerTitle: true,
            title: const Text('Stream'),
            floating: true,
            snap: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(65),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    width: MediaQuery.of(context).size.width,
                    height: 35,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        buildCategoryChip('All', 70),
                        buildCategoryChip('Sci-fi', 90),
                        buildCategoryChip('Music', 90),
                        buildCategoryChip('Punjabi', 100),
                        buildCategoryChip('Comedy', 100),
                        buildCategoryChip('Horre', 100),
                        buildCategoryChip('Drama', 100),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Upload(),
                    ),
                  );
                },
                icon: const CircleAvatar(
                  radius: 13,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 12,
                    child: Icon(
                      Icons.add,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<Map<String, dynamic>>(
              future: checkvalue(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching data'));
                }

                final data = snapshot.data!;
                List<VideoData> videos = [];
                data.forEach((key, value) {
                  videos.add(VideoData(
                    title: key,
                    link: value['videoLink'],
                    thumbnail: value['videoThumbnail'],
                    like: value['videoLike'],
                    dislike: value['videoDislike'],
                    artistName: value['artistName'],
                    date: value['date'],
                    duration: value['duration'],
                    trans: value['trans'],
                    tags: value['tags'],
                  ));
                });

                final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
                videos.sort((a, b) {
                  DateTime dateA = dateFormat.parse(a.date);
                  DateTime dateB = dateFormat.parse(b.date);
                  return dateB.compareTo(dateA);
                });

                videos = filterVideosByLabel(videos);

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
          ),
        ],
      ),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: Colors.white,
//       // appBar: AppBar(
//       //   centerTitle: true,
//       //   title: const Text('Stream'),
//       //   actions: [
//       //     IconButton(
//       //       onPressed: () {
//       //         setState(() {});
//       //       },
//       //       icon: const Icon(Icons.refresh),
//       //     ),
//       //     IconButton(
//       //         onPressed: () {
//       //           Navigator.push(
//       //               context,
//       //               MaterialPageRoute(
//       //                 builder: (context) => const Upload(),
//       //               ));
//       //         },
//       //         icon: const CircleAvatar(
//       //           radius: 13,
//       //           backgroundColor: Colors.white,
//       //           child: CircleAvatar(
//       //             backgroundColor: Colors.black,
//       //             radius: 12,
//       //             child: Icon(
//       //               Icons.add,
//       //               size: 17,
//       //               color: Colors.white,
//       //             ),
//       //           ),
//       //         )),
//       //   ],
//       // ),

//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             title: Text("YouTube-like App Bar"),
//             floating: true,
//             snap: true,
//             backgroundColor: Colors.red,
//             // expandedHeight: 200,
//             // flexibleSpace: FlexibleSpaceBar(
//             //   background: Container(
//             //     color: Colors.redAccent,
//             //     child: Center(
//             //       child: Text(
//             //         'App Bar Background',
//             //         style: TextStyle(color: Colors.white, fontSize: 24),
//             //       ),
//             //     ),
//             //   ),
//             // ),
//           ),
//           SliverFillRemaining(
//             child: FutureBuilder<Map<String, dynamic>>(
//               future: checkvalue(),
//               // future: readJsonFile(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return const Center(child: Text('Error fetching data'));
//                 }
//                 // final data = snapshot.data as List<String>;
//                 final data = snapshot.data!;

//                 // Extract video data from Firebase document
//                 List<VideoData> videos = [];
//                 data.forEach((key, value) {
//                   videos.add(VideoData(
//                     title: key,
//                     link: value['videoLink'],
//                     thumbnail: value['videoThumbnail'],
//                     like: value['videoLike'],
//                     dislike: value['videoDislike'],
//                     artistName: value['artistName'],
//                     date: value['date'],
//                     duration: value['duration'],
//                     trans: value['trans'],
//                     tags: value['tags'],
//                   ));
//                 });

//                 // Sort videos by date in descending order (newest first)
//                 final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
//                 videos.sort((a, b) {
//                   DateTime dateA = dateFormat.parse(a.date);
//                   DateTime dateB = dateFormat.parse(b.date);
//                   return dateB.compareTo(dateA);
//                 });

//                 if (!snapshot.hasData || videos.isEmpty) {
//                   return Center(
//                       child: SizedBox(
//                     height: 120,
//                     child: Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           formatedText(
//                               text: 'No Video Available!',
//                               fontFamily: 'Roboto',
//                               size: 20,
//                               fontweight: FontWeight.bold),
//                           formatedText(
//                               text: 'Try again later',
//                               fontFamily: 'Roboto',
//                               size: 12)
//                         ],
//                       ),
//                     ),
//                   ));
//                 }

//                 return ListView.builder(
//                   itemCount: videos.length,
//                   itemBuilder: (context, index) {
//                     final video = videos[index];
//                     return Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         children: [
//                           VideoPlayerWithButton(
//                             videoUrl: video.link,
//                             date: video.date,
//                             videoTitle: video.title,
//                             duration: video.duration,
//                             thumbnail: video.thumbnail,
//                             artistName: video.artistName,
//                             tags: video.tags,
//                           ),
//                           const SizedBox(height: 10),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),

//         ],
//       ),
//     );
//   }
// }

class VideoPlayerWithButton extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;
  final String date;
  final String duration;
  final String thumbnail;
  final List artistName;
  final List tags;

  VideoPlayerWithButton({
    Key? key,
    required this.videoUrl,
    required this.videoTitle,
    required this.date,
    required this.duration,
    required this.thumbnail,
    required this.artistName,
    required this.tags,
  }) : super(key: key);

  @override
  _VideoPlayerWithButtonState createState() => _VideoPlayerWithButtonState();
}

class _VideoPlayerWithButtonState extends State<VideoPlayerWithButton> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isSkipping = false;
  bool _ispeeking = false;
  bool _isLoading = false;

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _controller!.initialize();
    setState(() {
      _isInitialized = true;
      _isLoading = false;
      _controller!.play();
    });
    _controller?.addListener(() {
      setState(() {});
    });
    _controller!.setVolume(0);
    // _controller.addListener(_updateSubtitle);
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _controller?.pause();
    } else {
      if (!_isInitialized) {
        _initializeVideo();
      }
      _controller?.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  // void _enterFullScreen() {
  //   Navigator.of(context).push(MaterialPageRoute(
  //     builder: (context) => FullScreenVideoPlayer(controller: _controller!),
  //   ));
  // }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _startSkipPlay() async {
    if (!_controller!.value.isInitialized || _isSkipping) return;

    _isSkipping = true;
    _controller!.play();

    _controller!.addListener(() async {
      if (_isSkipping && _controller!.value.isPlaying) {
        final currentPosition = _controller!.value.position;
        final duration = _controller!.value.duration;

        // If video has at least 20 seconds left, skip ahead by 20
        if (currentPosition < duration - const Duration(seconds: 20)) {
          // await Future.delayed(const Duration(milliseconds: 700));

          await Future.delayed(const Duration(seconds: 2));
          await _controller!
              .seekTo(currentPosition + const Duration(seconds: 10));
        } else {
          // Stop playback if less than 20 seconds remain
          _isSkipping = false;
          _controller!.removeListener(() {}); // Remove listener when done
          _controller!.pause();
          _ispeeking = false;
        }
      }
    });
  }

  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller?.pause();
        setState(() {
          _ispeeking = false;
          _isInitialized = false;
        });

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Videoscreen(
                      videoUrl: widget.videoUrl,
                      videoThumbnail: widget.thumbnail,
                      videoTitle: widget.videoTitle,
                      uploaded: widget.date,
                      artistName: widget.artistName,
                      tags: widget.tags,
                    )));
      },
      onLongPressStart: (_) {
        log('longpress');
        setState(() {
          isSelected = isSelected;
        });
      },
      child: Column(
        children: [
          Stack(
            children: [
              _isInitialized && _ispeeking
                  ? Container(
                      decoration: BoxDecoration(
                          color: Colors.black,
                          // color: Colors.blue,
                          borderRadius: BorderRadius.circular(10)),
                      height: 220,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: widget.thumbnail,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[900]!,
                                highlightColor: Colors.grey[600]!,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[700],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.broken_image_outlined),
                            ),
                            // Image.network(
                            //   widget.thumbnail,
                            //   fit: BoxFit.fitHeight,
                            //   loadingBuilder: (BuildContext context,
                            //       Widget child,
                            //       ImageChunkEvent? loadingProgress) {
                            //     if (loadingProgress == null) {
                            //       return child; // Display the image once it's fully loaded
                            //     } else {
                            //       return Shimmer.fromColors(
                            //         baseColor: Colors.grey,
                            //         highlightColor: Colors.grey[100]!,
                            //         child: Container(
                            //           decoration: BoxDecoration(
                            //             color: Colors.grey[300],
                            //             borderRadius: BorderRadius.circular(10),
                            //           ),
                            //         ),
                            //       ); // Display shimmer effect while loading
                            //     }
                            //   },
                            // ),
                          ),
                        ),
                      ),
                    ),

              // if (_isPlaying)
              // Positioned(
              //   bottom: 10,
              //   right: 10,
              //   child: IconButton(
              //     icon: Icon(Icons.fullscreen, color: Colors.white),
              //     onPressed: _enterFullScreen,
              //   ),
              // ),
              Positioned(
                bottom: 0,
                right: 10,
                child: _isLoading
                    ? const CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 10,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ))
                    : IconButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          if (!_isInitialized) {
                            await _initializeVideo();
                            await Future.delayed(const Duration(seconds: 1));
                            _ispeeking = true;
                          }
                          _startSkipPlay();
                        },
                        icon: _isInitialized
                            ? const SizedBox.shrink()
                            : const Icon(Icons.remove_red_eye_outlined)),
              ),
            ],
          ),
          // _isInitialized && _isPlaying
          //     ? Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //         child: Column(
          //           children: [
          //             Slider(
          //               value: _controller!.value.position.inSeconds.toDouble(),
          //               min: 0.0,
          //               max: _controller!.value.duration.inSeconds.toDouble(),
          //               onChanged: (value) {
          //                 setState(() {
          //                   _controller!
          //                       .seekTo(Duration(seconds: value.toInt()));
          //                 });
          //               },
          //             ),
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               children: [
          //                 Text(formatDuration(_controller!.value.position)),
          //                 Text(formatDuration(_controller!.value.duration)),
          //               ],
          //             ),
          //           ],
          //         ),
          //       )
          //     : const SizedBox.shrink(),
          ListTile(
            title: Text(widget.videoTitle),
            trailing: Text(
              widget.duration,
              style: const TextStyle(fontSize: 15),
            ),
            subtitle: Text(timeAgo(widget.date)),
            // subtitle: Text(timeAgo('05/11/2024 00:02')),
          ),
        ],
      ),
    );
  }
}
