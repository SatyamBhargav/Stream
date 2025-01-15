// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final String title;

  FullScreenVideoPlayer({
    Key? key,
    required this.controller,
    required this.title,
  }) : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  bool _isControlsVisible = true;

  Timer? _timer;
  String? _subtitleText;
  List<Map<String, dynamic>> subtitles = [
    // {"start": 2, "end": 5, "text": "This is the first subtitle."},
    // {"start": 6, "end": 10, "text": "This is the second subtitle."}
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

  void _toggleControlsVisibility() async {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
    // await Future.delayed(const Duration(seconds: 3));
    // setState(() {
    //   _isControlsVisible = !_isControlsVisible;
    // });
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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.black,
  //     body: GestureDetector(
  //       onTap: _toggleControlsVisibility,
  //       child: Stack(
  //         children: [
  //           Center(
  //             child: AspectRatio(
  //               aspectRatio: widget.controller.value.aspectRatio,
  //               child: Stack(
  //                 children: [
  //                   VideoPlayer(widget.controller),
  //                   if (_subtitleText != null)
  //                     Align(
  //                       alignment: Alignment.bottomCenter,
  //                       child: Container(
  //                         color: Colors.black54,
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Text(
  //                           _subtitleText!,
  //                           // 'hello workd',
  //                           style: const TextStyle(color: Colors.white),
  //                           textAlign: TextAlign.center,
  //                         ),
  //                       ),
  //                     ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           if (_isControlsVisible)
  //             Container(
  //               height: MediaQuery.of(context).size.height,
  //               width: MediaQuery.of(context).size.width,
  //               color: Colors.black.withOpacity(0.3),
  //               padding: const EdgeInsets.all(8.0),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         formatDuration(widget.controller.value.position),
  //                         style: TextStyle(color: Colors.white),
  //                       ),
  //                       Expanded(
  //                         child: Slider(
  //                           value: widget.controller.value.position.inSeconds
  //                               .toDouble(),
  //                           min: 0.0,
  //                           max: widget.controller.value.duration.inSeconds
  //                               .toDouble(),
  //                           onChanged: (value) {
  //                             setState(() {
  //                               widget.controller
  //                                   .seekTo(Duration(seconds: value.toInt()));
  //                             });
  //                           },
  //                         ),
  //                       ),
  //                       Text(
  //                         formatDuration(widget.controller.value.duration),
  //                         style: const TextStyle(color: Colors.white),
  //                       ),
  //                     ],
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.only(right: 10),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       // mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         IconButton(
  //                             onPressed: () {
  //                               loadSubtitles();
  //                             },
  //                             icon: const Icon(Icons.subtitles_rounded)),
  //                         IconButton(
  //                           icon: const Icon(
  //                             Icons.screen_rotation_outlined,
  //                             color: Colors.white,
  //                             size: 20,
  //                           ),
  //                           onPressed: () {
  //                             if (MediaQuery.of(context).orientation ==
  //                                 Orientation.landscape) {
  //                               SystemChrome.setPreferredOrientations([
  //                                 DeviceOrientation.portraitUp,
  //                                 DeviceOrientation.portraitDown
  //                               ]);
  //                             } else {
  //                               SystemChrome.setPreferredOrientations([
  //                                 DeviceOrientation.landscapeRight,
  //                                 DeviceOrientation.landscapeLeft
  //                               ]);
  //                             }

  //                             // SystemChrome.setPreferredOrientations(
  //                             //     [DeviceOrientation.landscapeLeft]);
  //                           },
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           if (_isControlsVisible)
  //             Center(
  //               child: CircleAvatar(
  //                 backgroundColor: const Color.fromARGB(117, 0, 0, 0),
  //                 radius: 30,
  //                 child: IconButton(
  //                   icon: Icon(
  //                     widget.controller.value.isPlaying
  //                         ? Icons.pause
  //                         : Icons.play_arrow,
  //                     color: Colors.white,
  //                     size: 35,
  //                   ),
  //                   onPressed: _togglePlayPause,
  //                 ),
  //               ),
  //             ),
  //           if (_isControlsVisible)
  //             Positioned(
  //               top: 30,
  //               left: 10,
  //               child: Row(
  //                 children: [
  //                   IconButton(
  //                     icon: const Icon(
  //                       Icons.arrow_back,
  //                       color: Colors.white,
  //                       size: 20,
  //                     ),
  //                     onPressed: () => Navigator.of(context).pop(),
  //                   ),
  //                   Text(
  //                     widget.title,
  //                     style: const TextStyle(fontSize: 20),
  //                   )
  //                 ],
  //               ),
  //             ),
  //           // if (_isSkipControlsVisible)
  //         ],
  //       ),
  //     ),
  //   );
  // }
  bool _showSkipForwardEffect = false;
  bool _showSkipBackwardEffect = false;
  Timer? _effectTimer;

  void _triggerSkipEffect(bool isForward) {
    setState(() {
      if (isForward) {
        _showSkipForwardEffect = true;
      } else {
        _showSkipBackwardEffect = true;
      }
    });

    // Hide the effect after 500 milliseconds
    _effectTimer?.cancel();
    _effectTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _showSkipForwardEffect = false;
        _showSkipBackwardEffect = false;
      });
    });
  }

  void _skipVideo(int seconds) {
    final currentPosition = widget.controller.value.position;
    final newPosition = currentPosition + Duration(seconds: seconds);

    // Ensure the new position is within bounds
    if (newPosition >= Duration.zero &&
        newPosition <= widget.controller.value.duration) {
      widget.controller.seekTo(newPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Double-tap right side to skip forward
            GestureDetector(
              onDoubleTap: () {
                _skipVideo(10);
                _triggerSkipEffect(true);
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: screenWidth / 2,
                  color: Colors.transparent, // Ensures touch detection
                ),
              ),
            ),

            // Ripple effect for forward skip
            if (_showSkipForwardEffect)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        height: 100,
                        width: 100,
                        child: Center(
                          child: Text(
                            "+10",
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Ripple effect for backward skip
            if (_showSkipBackwardEffect)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        height: 100,
                        width: 100,
                        child: Center(
                          child: Text(
                            "-10",
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
                        children: [
                          IconButton(
                            onPressed: loadSubtitles,
                            icon: const Icon(Icons.subtitles_rounded),
                          ),
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

// Helper functions to skip forward and backward
  void _skipForward() {
    final currentPosition = widget.controller.value.position;
    final duration = widget.controller.value.duration;
    final newPosition =
        currentPosition + const Duration(seconds: 10) <= duration
            ? currentPosition + const Duration(seconds: 10)
            : duration;
    widget.controller.seekTo(newPosition);
  }

  void _skipBackward() {
    final currentPosition = widget.controller.value.position;
    final newPosition =
        currentPosition - const Duration(seconds: 10) >= Duration.zero
            ? currentPosition - const Duration(seconds: 10)
            : Duration.zero;
    widget.controller.seekTo(newPosition);
  }
}
