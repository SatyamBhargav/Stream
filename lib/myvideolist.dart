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
                        buildCategoryChip('Birthday', 90),
                        buildCategoryChip('House Warming', 140),
                        buildCategoryChip('Wedding', 100),
                        buildCategoryChip('Anniversary', 100),
                        buildCategoryChip('Save the date', 140),
                        buildCategoryChip('Baby shower', 130),
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
    _controller = VideoPlayerController.network(widget.videoUrl);
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

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final String title;
  // List<Map<String, dynamic>> subtitles;
  // final String? subtitleText;

  FullScreenVideoPlayer({
    Key? key,
    required this.controller,
    required this.title,
    // required this.subtitles,
    // required this.subtitleText,
  }) : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  bool _isControlsVisible = true;
  Timer? _timer;
  String? _subtitleText;
  List<Map<String, dynamic>> subtitles = [
    {"start": 2, "end": 5, "text": "This is the first subtitle."},
    {"start": 6, "end": 10, "text": "This is the second subtitle."}
    // Add more subtitles as needed
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable;
    _startUpdating();
    widget.controller.addListener(() {
      _updateSubtitle();
    });
  }

  void _startUpdating() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (widget.controller.value.isPlaying) {
        widget.controller.pause();
        WakelockPlus.disable(); // Disable wakelock when paused
      } else {
        widget.controller.play();
        WakelockPlus.enable(); // Enable wakelock when playing
      }
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    WakelockPlus.disable();
    widget.controller.removeListener(_updateSubtitle);

    super.dispose();
  }

  void _updateSubtitle() {
    final currentTime = widget.controller.value.position.inSeconds;
    String? newSubtitle;
    for (var subtitle in subtitles) {
      if (currentTime >= subtitle['start'] && currentTime <= subtitle['end']) {
        newSubtitle = subtitle['text'];
        break;
      }
    }
    if (newSubtitle != _subtitleText) {
      setState(() {
        _subtitleText = newSubtitle;
      });
    }
  }

  Future<void> loadSubtitles() async {
    try {
      // Open a file picker to select the .srt subtitle file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          // type: FileType.custom,
          // allowedExtensions: ['srt'], // Only allow .srt files
          );

      if (result != null) {
        // Read the content of the selected file
        File subtitleFile = File(result.files.single.path!);
        String fileContent = await subtitleFile.readAsString();

        // Parse the .srt file and extract subtitles
        List<Map<String, dynamic>> parsedSubtitles = parseSrtFile(fileContent);

        // Update your subtitle list
        subtitles = parsedSubtitles;
        if (kDebugMode) {
          print('Subtitles loaded successfully');
        }
      } else {
        if (kDebugMode) {
          print('No file selected');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading subtitles: $e');
      }
    }
  }

// Function to parse an .srt file into a list of subtitle maps
  List<Map<String, dynamic>> parseSrtFile(String content) {
    List<Map<String, dynamic>> parsedSubtitles = [];
    List<String> lines = content.split('\n');
    int index = 0;

    while (index < lines.length) {
      // Check for a subtitle block
      String line = lines[index].trim();
      if (line.isEmpty) {
        index++;
        continue;
      }

      // Parse the subtitle index
      int subtitleIndex = int.tryParse(line) ?? -1;
      if (subtitleIndex != -1) {
        // Parse the time range
        index++;
        String timeRange = lines[index].trim();
        List<String> times = timeRange.split(' --> ');
        if (times.length == 2) {
          int startTime = _timeToMilliseconds(times[0]);
          int endTime = _timeToMilliseconds(times[1]);

          // Parse the subtitle text
          index++;
          String subtitleText = '';
          while (index < lines.length && lines[index].trim().isNotEmpty) {
            subtitleText += '${lines[index].trim()}\n';
            index++;
          }

          // Add to parsedSubtitles
          parsedSubtitles.add({
            'start': startTime ~/ 1000, // Convert to seconds
            'end': endTime ~/ 1000, // Convert to seconds
            'text': subtitleText.trim(),
          });
        }
      }
      index++;
    }

    return parsedSubtitles;
  }

// Helper function to convert time string to milliseconds
  int _timeToMilliseconds(String time) {
    List<String> parts = time.split(':');
    List<String> secondsAndMilliseconds = parts[2].split(',');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(secondsAndMilliseconds[0]);
    int milliseconds = int.parse(secondsAndMilliseconds[1]);

    return (((hours * 60 + minutes) * 60 + seconds) * 1000 + milliseconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControlsVisibility,
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: Stack(
                  children: [
                    VideoPlayer(widget.controller),
                    if (_subtitleText != null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _subtitleText!,
                            // 'hello workd',
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_isControlsVisible)
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.black.withOpacity(0.3),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDuration(widget.controller.value.position),
                          style: TextStyle(color: Colors.white),
                        ),
                        Expanded(
                          child: Slider(
                            value: widget.controller.value.position.inSeconds
                                .toDouble(),
                            min: 0.0,
                            max: widget.controller.value.duration.inSeconds
                                .toDouble(),
                            onChanged: (value) {
                              setState(() {
                                widget.controller
                                    .seekTo(Duration(seconds: value.toInt()));
                              });
                            },
                          ),
                        ),
                        Text(
                          formatDuration(widget.controller.value.duration),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                loadSubtitles();
                              },
                              icon: const Icon(Icons.subtitles_rounded)),
                          IconButton(
                            icon: const Icon(
                              Icons.screen_rotation_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              if (MediaQuery.of(context).orientation ==
                                  Orientation.landscape) {
                                SystemChrome.setPreferredOrientations([
                                  DeviceOrientation.portraitUp,
                                  DeviceOrientation.portraitDown
                                ]);
                              } else {
                                SystemChrome.setPreferredOrientations([
                                  DeviceOrientation.landscapeRight,
                                  DeviceOrientation.landscapeLeft
                                ]);
                              }

                              // SystemChrome.setPreferredOrientations(
                              //     [DeviceOrientation.landscapeLeft]);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (_isControlsVisible)
              Center(
                child: CircleAvatar(
                  backgroundColor: const Color.fromARGB(117, 0, 0, 0),
                  radius: 30,
                  child: IconButton(
                    icon: Icon(
                      widget.controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 35,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),
              ),
            if (_isControlsVisible)
              Positioned(
                top: 30,
                left: 10,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      widget.title,
                      style: const TextStyle(fontSize: 20),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// class VideoPlayerWithButton extends StatefulWidget {
//   final String videoUrl;
//   final String date;
//   final String videoTitle;
//   // final String videoTitle;
//   // final String pageTitle;
//   // final String productID;

//   VideoPlayerWithButton({
//     Key? key,
//     required this.videoUrl,
//     required this.date,
//     required this.videoTitle,
//   }) : super(key: key);

//   @override
//   _VideoPlayerWithButtonState createState() => _VideoPlayerWithButtonState();
// }

// class _VideoPlayerWithButtonState extends State<VideoPlayerWithButton> {
//   VideoPlayerController? _controller;
//   bool _isInitialized = false;
//   bool _isPlaying = false;

//   void _initializeVideo() {
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {
//           _isInitialized = true;
//         });
//       });
//   }

//   void _togglePlayPause() {
//     if (_isPlaying) {
//       _controller?.pause();
//     } else {
//       if (!_isInitialized) {
//         _initializeVideo();
//       }
//       _controller?.play();
//     }
//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _togglePlayPause,
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               _isInitialized
//                   ? Container(
//                       decoration: BoxDecoration(
//                           color: Colors.black,
//                           borderRadius: BorderRadius.circular(10)),
//                       height: 338,
//                       width: MediaQuery.of(context).size.width,
//                       child: Center(
//                         child: AspectRatio(
//                           aspectRatio: _controller!.value.aspectRatio,
//                           child: VideoPlayer(_controller!),
//                         ),
//                       ),
//                     )
//                   : Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Container(
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: const Color(0xffd5e6e2)),
//                         height: 338,
//                       ),
//                     ),
//               if (!_isPlaying)
//                 Positioned.fill(
//                   child: IconButton(
//                     icon: const CircleAvatar(
//                       backgroundColor: Colors.white,
//                       radius: 30,
//                       child: Icon(Icons.play_arrow,
//                           size: 44, color: Color(0xff6D51CE)),
//                     ),
//                     onPressed: _togglePlayPause,
//                   ),
//                 ),
//             ],
//           ),
//           ListTile(
//             // title: Text(widget.videoUrl),
//             title: Text('Working Out'),
//             trailing: const Text(
//               '20:23',
//               style: TextStyle(fontSize: 15),
//             ),
//             subtitle: Text('1 day ago'),
//           )
//         ],
//       ),
//     );
//   }
// }
//******************************** vidoe with seek bar *********************************************** */
// class VideoPlayerWithButton extends StatefulWidget {
//   final String videoUrl;
//   final String pageTitle;

//   VideoPlayerWithButton({
//     required this.videoUrl,
//     required this.pageTitle,
//   });

//   @override
//   _VideoPlayerWithButtonState createState() => _VideoPlayerWithButtonState();
// }

// class _VideoPlayerWithButtonState extends State<VideoPlayerWithButton> {
//   late VideoPlayerController _controller;
//   bool _isInitialized = false;
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideo();
//   }

//   void _initializeVideo() {
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {
//           _isInitialized = true;
//         });
//       });
//     _controller.addListener(() {
//       setState(() {}); // Update the UI to show current playback time
//     });
//   }

//   void _togglePlayPause() {
//     if (_isPlaying) {
//       _controller.pause();
//     } else {
//       if (!_isInitialized) {
//         _initializeVideo();
//       }
//       _controller.play();
//     }
//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   String formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return "$minutes:$seconds";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _togglePlayPause,
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               _isInitialized
//                   ? Container(
//                       decoration: BoxDecoration(
//                           color: Colors.black,
//                           borderRadius: BorderRadius.circular(10)),
//                       height: 338,
//                       width: MediaQuery.of(context).size.width,
//                       child: Center(
//                         child: AspectRatio(
//                           aspectRatio: _controller.value.aspectRatio,
//                           child: VideoPlayer(_controller),
//                         ),
//                       ),
//                     )
//                   : Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Container(
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: const Color(0xffd5e6e2)),
//                         height: 338,
//                       ),
//                     ),
//               if (!_isPlaying)
//                 Positioned.fill(
//                   child: IconButton(
//                     icon: const CircleAvatar(
//                       backgroundColor: Colors.white,
//                       radius: 30,
//                       child: Icon(Icons.play_arrow,
//                           size: 44, color: Color(0xff6D51CE)),
//                     ),
//                     onPressed: _togglePlayPause,
//                   ),
//                 ),
//             ],
//           ),
//           _isInitialized
//               ? Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Column(
//                     children: [
//                       Slider(
//                         value: _controller.value.position.inSeconds.toDouble(),
//                         min: 0.0,
//                         max: _controller.value.duration.inSeconds.toDouble(),
//                         onChanged: (value) {
//                           setState(() {
//                             _controller
//                                 .seekTo(Duration(seconds: value.toInt()));
//                           });
//                         },
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(formatDuration(_controller.value.position)),
//                           Text(formatDuration(_controller.value.duration)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 )
//               : SizedBox.shrink(),
//           ListTile(
//             title: Text('Working Out'),
//             trailing: Text(
//               formatDuration(_controller.value.duration),
//               style: TextStyle(fontSize: 15),
//             ),
//             subtitle: Text('1 day ago'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//************************************ with full screen button ****************************************** */
// class VideoPlayerWithButton extends StatefulWidget {
//   final String videoUrl;
//   final String pageTitle;

//   VideoPlayerWithButton({
//     required this.videoUrl,
//     required this.pageTitle,
//   });

//   @override
//   _VideoPlayerWithButtonState createState() => _VideoPlayerWithButtonState();
// }

// class _VideoPlayerWithButtonState extends State<VideoPlayerWithButton> {
//   late VideoPlayerController _controller;
//   bool _isInitialized = false;
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideo();
//   }

//   void _initializeVideo() {
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {
//           _isInitialized = true;
//         });
//       });
//     _controller.addListener(() {
//       setState(() {}); // Update the UI to show current playback time
//     });
//   }

//   void _togglePlayPause() {
//     if (_isPlaying) {
//       _controller.pause();
//     } else {
//       if (!_isInitialized) {
//         _initializeVideo();
//       }
//       _controller.play();
//     }
//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//   }

//   void _enterFullScreen() {
//     Navigator.of(context).push(MaterialPageRoute(
//       builder: (context) => FullScreenVideoPlayer(
//         controller: _controller,
//       ),
//     ));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   String formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return "$minutes:$seconds";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _togglePlayPause,
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               _isInitialized
//                   ? Container(
//                       decoration: BoxDecoration(
//                           color: Colors.black,
//                           borderRadius: BorderRadius.circular(10)),
//                       height: 338,
//                       width: MediaQuery.of(context).size.width,
//                       child: Center(
//                         child: AspectRatio(
//                           aspectRatio: _controller.value.aspectRatio,
//                           child: VideoPlayer(_controller),
//                         ),
//                       ),
//                     )
//                   : Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Container(
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: const Color(0xffd5e6e2)),
//                         height: 338,
//                       ),
//                     ),
//               if (!_isPlaying)
//                 Positioned.fill(
//                   child: IconButton(
//                     icon: const CircleAvatar(
//                       backgroundColor: Colors.white,
//                       radius: 30,
//                       child: Icon(Icons.play_arrow,
//                           size: 44, color: Color(0xff6D51CE)),
//                     ),
//                     onPressed: _togglePlayPause,
//                   ),
//                 ),
//               Positioned(
//                 bottom: 10,
//                 right: 10,
//                 child: IconButton(
//                   icon: Icon(Icons.fullscreen, color: Colors.white),
//                   onPressed: _enterFullScreen,
//                 ),
//               ),
//             ],
//           ),
//           _isInitialized
//               ? Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Column(
//                     children: [
//                       Slider(
//                         value: _controller.value.position.inSeconds.toDouble(),
//                         min: 0.0,
//                         max: _controller.value.duration.inSeconds.toDouble(),
//                         onChanged: (value) {
//                           setState(() {
//                             _controller
//                                 .seekTo(Duration(seconds: value.toInt()));
//                           });
//                         },
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(formatDuration(_controller.value.position)),
//                           Text(formatDuration(_controller.value.duration)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 )
//               : SizedBox.shrink(),
//           ListTile(
//             title: Text('Working Out'),
//             trailing: const Text(
//               '20:23',
//               style: TextStyle(fontSize: 15),
//             ),
//             subtitle: Text('1 day ago'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class FullScreenVideoPlayer extends StatelessWidget {
//   final VideoPlayerController controller;

//   FullScreenVideoPlayer({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: AspectRatio(
//           aspectRatio: controller.value.aspectRatio,
//           child: VideoPlayer(controller),
//         ),
//       ),
//     );
//   }
// }
//************************ full screen have video controler but it is in the center of the video ******************************************************* */
// class VideoPlayerWithButton extends StatefulWidget {
//   final String videoUrl;
//   final String pageTitle;

//   VideoPlayerWithButton({
//     required this.videoUrl,
//     required this.pageTitle,
//   });

//   @override
//   _VideoPlayerWithButtonState createState() => _VideoPlayerWithButtonState();
// }

// class _VideoPlayerWithButtonState extends State<VideoPlayerWithButton> {
//   late VideoPlayerController _controller;
//   bool _isInitialized = false;
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideo();
//   }

//   void _initializeVideo() {
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {
//           _isInitialized = true;
//         });
//       });
//     _controller.addListener(() {
//       setState(() {});
//     });
//   }

//   void _togglePlayPause() {
//     if (_isPlaying) {
//       _controller.pause();
//     } else {
//       if (!_isInitialized) {
//         _initializeVideo();
//       }
//       _controller.play();
//     }
//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//   }

//   void _enterFullScreen() {
//     Navigator.of(context).push(MaterialPageRoute(
//       builder: (context) => FullScreenVideoPlayer(controller: _controller),
//     ));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   String formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return "$minutes:$seconds";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _togglePlayPause,
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               _isInitialized
//                   ? Container(
//                       decoration: BoxDecoration(
//                           color: Colors.black,
//                           borderRadius: BorderRadius.circular(10)),
//                       height: 338,
//                       width: MediaQuery.of(context).size.width,
//                       child: Center(
//                         child: AspectRatio(
//                           aspectRatio: _controller.value.aspectRatio,
//                           child: VideoPlayer(_controller),
//                         ),
//                       ),
//                     )
//                   : Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Container(
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: const Color(0xffd5e6e2)),
//                         height: 338,
//                       ),
//                     ),
//               if (!_isPlaying)
//                 Positioned.fill(
//                   child: IconButton(
//                     icon: const CircleAvatar(
//                       backgroundColor: Colors.white,
//                       radius: 30,
//                       child: Icon(Icons.play_arrow,
//                           size: 44, color: Color(0xff6D51CE)),
//                     ),
//                     onPressed: _togglePlayPause,
//                   ),
//                 ),
//               Positioned(
//                 bottom: 10,
//                 right: 10,
//                 child: IconButton(
//                   icon: Icon(Icons.fullscreen, color: Colors.white),
//                   onPressed: _enterFullScreen,
//                 ),
//               ),
//             ],
//           ),
//           _isInitialized && _isPlaying
//               ? Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Column(
//                     children: [
//                       Slider(
//                         value: _controller.value.position.inSeconds.toDouble(),
//                         min: 0.0,
//                         max: _controller.value.duration.inSeconds.toDouble(),
//                         onChanged: (value) {
//                           setState(() {
//                             _controller
//                                 .seekTo(Duration(seconds: value.toInt()));
//                           });
//                         },
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(formatDuration(_controller.value.position)),
//                           Text(formatDuration(_controller.value.duration)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 )
//               : SizedBox.shrink(),
//           ListTile(
//             title: Text('Working Out'),
//             trailing: const Text(
//               '20:23',
//               style: TextStyle(fontSize: 15),
//             ),
//             subtitle: Text('1 day ago'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class FullScreenVideoPlayer extends StatefulWidget {
//   final VideoPlayerController controller;

//   FullScreenVideoPlayer({required this.controller});

//   @override
//   _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
// }

// class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
//   bool _isControlsVisible = true;

//   void _toggleControlsVisibility() {
//     setState(() {
//       _isControlsVisible = !_isControlsVisible;
//     });
//   }

//   void _togglePlayPause() {
//     setState(() {
//       if (widget.controller.value.isPlaying) {
//         widget.controller.pause();
//       } else {
//         widget.controller.play();
//       }
//     });
//   }

//   String formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return "$minutes:$seconds";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: GestureDetector(
//         onTap: _toggleControlsVisibility,
//         child: Stack(
//           children: [
//             Center(
//               child: AspectRatio(
//                 aspectRatio: widget.controller.value.aspectRatio,
//                 child: VideoPlayer(widget.controller),
//               ),
//             ),
//             if (_isControlsVisible)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black.withOpacity(0.3),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         icon: Icon(
//                           widget.controller.value.isPlaying
//                               ? Icons.pause
//                               : Icons.play_arrow,
//                           color: Colors.white,
//                           size: 50,
//                         ),
//                         onPressed: _togglePlayPause,
//                       ),
//                       Slider(
//                         value: widget.controller.value.position.inSeconds
//                             .toDouble(),
//                         min: 0.0,
//                         max: widget.controller.value.duration.inSeconds
//                             .toDouble(),
//                         onChanged: (value) {
//                           setState(() {
//                             widget.controller
//                                 .seekTo(Duration(seconds: value.toInt()));
//                           });
//                         },
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             child: Text(
//                               formatDuration(widget.controller.value.position),
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             child: Text(
//                               formatDuration(widget.controller.value.duration),
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             Positioned(
//               top: 30,
//               left: 10,
//               child: IconButton(
//                 icon: Icon(Icons.arrow_back, color: Colors.white),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//************************************ seek bar and timer not updating while video is palying and the control are visible in full screen section ***************************************************** */

// class VideoPlayerWithButton extends StatefulWidget {
//   final String videoUrl;
//   final String pageTitle;

//   VideoPlayerWithButton({
//     required this.videoUrl,
//     required this.pageTitle,
//   });

//   @override
//   _VideoPlayerWithButtonState createState() => _VideoPlayerWithButtonState();
// }

// class _VideoPlayerWithButtonState extends State<VideoPlayerWithButton> {
//   late VideoPlayerController _controller;
//   bool _isInitialized = false;
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideo();
//   }

//   void _initializeVideo() {
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {
//           _isInitialized = true;
//         });
//       });
//     _controller.addListener(() {
//       setState(() {});
//     });
//   }

//   void _togglePlayPause() {
//     if (_isPlaying) {
//       _controller.pause();
//     } else {
//       if (!_isInitialized) {
//         _initializeVideo();
//       }
//       _controller.play();
//     }
//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//   }

//   void _enterFullScreen() {
//     Navigator.of(context).push(MaterialPageRoute(
//       builder: (context) => FullScreenVideoPlayer(controller: _controller),
//     ));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   String formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return "$minutes:$seconds";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _togglePlayPause,
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               _isInitialized
//                   ? Container(
//                       decoration: BoxDecoration(
//                           color: Colors.black,
//                           borderRadius: BorderRadius.circular(10)),
//                       height: 338,
//                       width: MediaQuery.of(context).size.width,
//                       child: Center(
//                         child: AspectRatio(
//                           aspectRatio: _controller.value.aspectRatio,
//                           child: VideoPlayer(_controller),
//                         ),
//                       ),
//                     )
//                   : Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Container(
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: const Color(0xffd5e6e2)),
//                         height: 338,
//                       ),
//                     ),
//               if (!_isPlaying)
//                 Positioned.fill(
//                   child: IconButton(
//                     icon: const CircleAvatar(
//                       backgroundColor: Colors.white,
//                       radius: 30,
//                       child: Icon(Icons.play_arrow,
//                           size: 44, color: Color(0xff6D51CE)),
//                     ),
//                     onPressed: _togglePlayPause,
//                   ),
//                 ),
//               if (_isPlaying)
//                 Positioned(
//                   bottom: 10,
//                   right: 10,
//                   child: IconButton(
//                     icon: Icon(Icons.fullscreen, color: Colors.white),
//                     onPressed: _enterFullScreen,
//                   ),
//                 ),
//             ],
//           ),
//           _isInitialized && _isPlaying
//               ? Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Column(
//                     children: [
//                       Slider(
//                         value: _controller.value.position.inSeconds.toDouble(),
//                         min: 0.0,
//                         max: _controller.value.duration.inSeconds.toDouble(),
//                         onChanged: (value) {
//                           setState(() {
//                             _controller
//                                 .seekTo(Duration(seconds: value.toInt()));
//                           });
//                         },
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(formatDuration(_controller.value.position)),
//                           Text(formatDuration(_controller.value.duration)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 )
//               : SizedBox.shrink(),
//           ListTile(
//             title: Text('Working Out'),
//             trailing: Text(
//               formatDuration(_controller.value.duration),
//               style: TextStyle(fontSize: 15),
//             ),
//             subtitle: Text('1 day ago'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class FullScreenVideoPlayer extends StatefulWidget {
//   final VideoPlayerController controller;

//   FullScreenVideoPlayer({required this.controller});

//   @override
//   _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
// }

// class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
//   bool _isControlsVisible = true;

//   void _toggleControlsVisibility() {
//     setState(() {
//       _isControlsVisible = !_isControlsVisible;
//     });
//   }

//   void _togglePlayPause() {
//     setState(() {
//       if (widget.controller.value.isPlaying) {
//         widget.controller.pause();
//       } else {
//         widget.controller.play();
//       }
//     });
//   }

//   String formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return "$minutes:$seconds";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: GestureDetector(
//         onTap: _toggleControlsVisibility,
//         child: Stack(
//           children: [
//             Center(
//               child: AspectRatio(
//                 aspectRatio: widget.controller.value.aspectRatio,
//                 child: VideoPlayer(widget.controller),
//               ),
//             ),
//             if (_isControlsVisible)
//               Positioned(
//                 bottom: 15,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   color: Colors.black.withOpacity(0.3),
//                   padding: const EdgeInsets.symmetric(horizontal: 25),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(
//                           widget.controller.value.isPlaying
//                               ? Icons.pause
//                               : Icons.play_arrow,
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                         onPressed: _togglePlayPause,
//                       ),
//                       Slider(
//                         value: widget.controller.value.position.inSeconds
//                             .toDouble(),
//                         min: 0.0,
//                         max: widget.controller.value.duration.inSeconds
//                             .toDouble(),
//                         onChanged: (value) {
//                           setState(() {
//                             widget.controller
//                                 .seekTo(Duration(seconds: value.toInt()));
//                           });
//                         },
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             formatDuration(widget.controller.value.position),
//                             style: TextStyle(color: Colors.white),
//                           ),
//                           Text(
//                             formatDuration(widget.controller.value.duration),
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             Positioned(
//               top: 30,
//               left: 10,
//               child: IconButton(
//                 icon: Icon(Icons.arrow_back, color: Colors.white),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
