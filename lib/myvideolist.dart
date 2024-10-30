// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import 'package:videostream/multi_use_widget.dart';
import 'package:videostream/upload.dart';

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
  bool isDownloading = false;

  Future<Map<String, dynamic>> checkvalue() async {
    try {
      final response = await http.get(
          Uri.parse('http://192.168.1.114/videos/video_json/videostream.json'));
      if (response.statusCode == 200) {
        // log(response.body);
        // Parse the HTML document
        final Map<String, dynamic> videoLinks = jsonDecode(response.body);
        return videoLinks;
      } else {
        log('Failed to load videos. Status code: ${response.statusCode}');
        return {
          "hello": ['notworking']
        };
      }
    } catch (e) {
      log('Error fetching videos: $e');
      return {
        "hello catch": ['notworking catch']
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Streamer'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Upload(),
                    ));
              },
              icon: const Icon(Icons.upload))
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: checkvalue(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }
          // final data = snapshot.data as List<String>;
          final data = snapshot.data!;

          // Extract video data from Firebase document
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

          if (!snapshot.hasData || videos.isEmpty) {
            return Center(
                child: SizedBox(
              height: 120,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    formatedText(
                        text: 'No Video Available!',
                        fontFamily: 'Roboto',
                        size: 20,
                        fontweight: FontWeight.bold),
                    formatedText(
                        text: 'Try again later', fontFamily: 'Roboto', size: 12)
                  ],
                ),
              ),
            ));
          }

          return ListView.builder(
            // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //   crossAxisCount: 2, // 2 videos per row
            //   childAspectRatio: 1.0,
            //   mainAxisExtent: 450,
            // ),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    VideoPlayerWithButton(
                      videoUrl: video.link,
                      date: video.date,
                      videoTitle: video.title,
                      duration: video.duration,
                      thumbnail: video.thumbnail,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          );
        },
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

class VideoPlayerWithButton extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;
  final String date;
  final String duration;
  final String thumbnail;

  VideoPlayerWithButton({
    Key? key,
    required this.videoUrl,
    required this.videoTitle,
    required this.date,
    required this.duration,
    required this.thumbnail,
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

  // @override
  // void initState() {
  //   super.initState();
  //   _initializeVideo();
  // }

  // void _initializeVideo() {
  //   _controller = VideoPlayerController.network(widget.videoUrl)
  //     ..initialize().then((_) {
  //       setState(() {
  //         _isInitialized = true;
  //       });
  //     });
  //   _controller?.addListener(() {
  //     setState(() {});
  //   });
  // }
  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.network(widget.videoUrl);
    await _controller!.initialize();
    setState(() {
      _isInitialized = true;
      _controller!.play();
    });
    _controller?.addListener(() {
      setState(() {});
    });
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

  void _enterFullScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FullScreenVideoPlayer(controller: _controller!),
    ));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
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
          await Future.delayed(const Duration(milliseconds: 700));

          await _controller!
              .seekTo(currentPosition + const Duration(seconds: 10));
          // await Future.delayed(Duration(seconds: 5));
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

  String timeAgo(String dateString) {
    DateFormat format = DateFormat('dd/MM/yyyy');
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: _togglePlayPause,
      onTap: () async {
        await Future.delayed(const Duration(seconds: 1));
        if (!_isInitialized) {
          await _initializeVideo();
          await Future.delayed(
              const Duration(seconds: 1)); // Ensure initialization delay
        }
        _enterFullScreen();
      },
      child: Column(
        children: [
          Stack(
            children: [
              _isInitialized && _ispeeking
                  ? Container(
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10)),
                      height: 338,
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
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // color: const Color(0xffd5e6e2),
                        ),
                        height: 338,
                        width: 400,
                        child: Image.network(
                          widget.thumbnail,
                        ),
                      ),
                    ),
              // if (!_isPlaying)
              //   Positioned.fill(
              //     child: IconButton(
              //       icon: const CircleAvatar(
              //         backgroundColor: Colors.white,
              //         radius: 30,
              //         child: Icon(Icons.play_arrow,
              //             size: 44, color: Color(0xff6D51CE)),
              //       ),
              //       onPressed: _togglePlayPause,
              //     ),
              //   ),
              if (_isPlaying)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.fullscreen, color: Colors.white),
                    onPressed: _enterFullScreen,
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 10,
                child: IconButton(
                    onPressed: () async {
                      if (!_isInitialized) {
                        await _initializeVideo();
                        await Future.delayed(const Duration(seconds: 1));
                        _ispeeking = true;
                      }
                      _startSkipPlay();
                    },

                    // onPressed: () async {
                    //   await _initializeVideo();
                    //   // await Future.delayed(Durations.medium4);
                    //   _startSkipPlay();
                    // },
                    icon: const Icon(Icons.remove_red_eye_outlined)),
              )
            ],
          ),
          _isInitialized && _isPlaying
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Slider(
                        value: _controller!.value.position.inSeconds.toDouble(),
                        min: 0.0,
                        max: _controller!.value.duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          setState(() {
                            _controller!
                                .seekTo(Duration(seconds: value.toInt()));
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatDuration(_controller!.value.position)),
                          Text(formatDuration(_controller!.value.duration)),
                        ],
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
          ListTile(
            title: Text(widget.videoTitle),
            trailing: Text(
              widget.duration,
              style: const TextStyle(fontSize: 15),
            ),
            subtitle: Text(timeAgo(widget.date)),
          ),
        ],
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  FullScreenVideoPlayer({required this.controller});

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  bool _isControlsVisible = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startUpdating();
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
      } else {
        widget.controller.play();
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
    super.dispose();
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
                child: VideoPlayer(widget.controller),
              ),
            ),
            if (_isControlsVisible)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          widget.controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                      Slider(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDuration(widget.controller.value.position),
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            formatDuration(widget.controller.value.duration),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              top: 30,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
