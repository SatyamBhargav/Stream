// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:videostream/multi_use_widget.dart';
import 'package:videostream/myvideolist.dart';

class Videoscreen extends StatefulWidget {
  final String videoUrl;
  final String videoThumbnail;
  final String videoTitle;
  final String uploaded;
  final List artistName;
  final List tags;

  const Videoscreen({
    Key? key,
    required this.videoUrl,
    required this.videoThumbnail,
    required this.videoTitle,
    required this.uploaded,
    required this.artistName,
    required this.tags,
  }) : super(key: key);

  @override
  State<Videoscreen> createState() => _VideoscreenState();
}

class _VideoscreenState extends State<Videoscreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isExpanded = false;

  void _initializeVideo() {
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
          _isInitialized = true;
        });
        // _isPlaying = true;
        // _controller!.play();
      });
    _controller?.addListener(() {
      setState(() {});
      if (_controller!.value.position == _controller!.value.duration &&
          _isInitialized) {
        setState(() {
          // _controller!.pause(); // Pause the video at the end
          _isPlaying = false;
        });
      }
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
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _togglePlayPause(),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _isInitialized
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
                          : Container(
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 62, 62, 62)),
                              child: Image.network(widget.videoThumbnail),
                            ),
                    ),
                    if (!_isPlaying)
                      Positioned.fill(
                        child: IconButton(
                            icon: CircleAvatar(
                                backgroundColor:
                                    const Color.fromARGB(58, 0, 0, 0),
                                radius: 30,
                                child: _controller != null
                                    ? _controller!.value.position ==
                                            _controller!.value.duration
                                        ? const Icon(
                                            Icons.replay,
                                            size: 44,
                                            color: Colors.white,
                                          )
                                        : const Icon(
                                            Icons.play_arrow,
                                            size: 44,
                                            color: Colors.white,
                                          )
                                    : const Icon(
                                        Icons.play_arrow,
                                        size: 44,
                                        color: Colors.white,
                                      )),
                            onPressed: () {
                              if (!_isInitialized) {
                                setState(() {
                                  _isLoading = true;
                                });
                              }
                              _togglePlayPause();
                            }),
                      ),
                    if (_isPlaying && !_isLoading)
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: IconButton(
                          icon:
                              const Icon(Icons.fullscreen, color: Colors.white),
                          onPressed: _enterFullScreen,
                        ),
                      ),
                    if (_isLoading)
                      const Positioned.fill(
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 30,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // _isInitialized && _isPlaying
              //     ?
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _controller == null
                        ? const Text('00:00')
                        : Text(formatDuration(_controller!.value.position)),
                    Expanded(
                      child: Slider(
                        // inactiveColor: Colors.transparent,
                        thumbColor: _controller == null
                            ? Colors.transparent
                            : Colors.purple,
                        value: _controller == null
                            ? 0
                            : _controller!.value.position.inSeconds.toDouble(),
                        min: 0.0,
                        max: _controller == null
                            ? 0
                            : _controller!.value.duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          if (_isInitialized) {
                            setState(() {
                              _controller!
                                  .seekTo(Duration(seconds: value.toInt()));
                            });
                          }
                        },
                      ),
                    ),
                    _controller == null
                        ? const Text('00:00')
                        : Text(formatDuration(_controller!.value.duration)),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [],
                    // ),
                  ],
                ),
              ),
              // : const SizedBox.shrink(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.videoTitle),
                        Text(timeAgo(widget.uploaded))
                        // Text(timeAgo('04/11/2024 12:30'))
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                        onPressed: () {},
                        child: const Row(
                          children: [
                            Text('Download'),
                            SizedBox(width: 5),
                            Icon(
                              Icons.arrow_downward_sharp,
                              size: 17,
                            )
                          ],
                        ))
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.thumb_up_alt_outlined)),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.thumb_down_alt_outlined)),
                ],
              ),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ExpansionTile(
                  title: const Text('Video Info'),
                  trailing: _isExpanded
                      ? const Text('Show less')
                      : const Text('Show more'),
                  tilePadding:
                      EdgeInsets.zero, // Removes padding around the tile
                  collapsedBackgroundColor:
                      Colors.transparent, // Removes default background color
                  backgroundColor: Colors
                      .transparent, // Removes default background color when expanded
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero), // Removes border shape
                  onExpansionChanged: (bool isexpanded) {
                    setState(() {
                      _isExpanded = isexpanded;
                    });
                  },
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text('Vidoe Title : ${widget.videoTitle}'),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text('Uploaded On : ${widget.uploaded}'),
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child:
                            Text('Artist : ${widget.artistName.join(', ')}')),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text('Tags : ${widget.tags.join(', ')}')),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
