// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:videostream/core/utility/textformater.dart';
import 'package:videostream/core/utility/time_manupulator.dart';
import 'package:videostream/features/home/domain/entities/video_entity.dart';
import 'package:videostream/features/videoplayer/presentation/pages/fullscreen.dart';

// import 'package:videostream/multi_use_widget.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoEntity video;

  const VideoPlayerScreen({
    super.key,
    required this.video,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isExpanded = false;

  void _initializeVideo() {
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.video.link!))
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
      builder: (context) => FullScreenVideoPlayer(
        controller: _controller!,
        title: widget.video.title!,
      ),
    ));
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }

  TextEditingController title = TextEditingController();
  TextEditingController artistName = TextEditingController();
  TextEditingController tags = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 600,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            // mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(height: 20),
                              formatedText(
                                  text: 'Video Info', fontFamily: 'Roboto'),
                              const SizedBox(height: 20),
                              Form(
                                  child: Column(
                                children: [
                                  TextFormField(
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        label: const Text('Video Title')),
                                  )
                                ],
                              )),
                              const SizedBox(height: 20),
                              Form(
                                  child: Column(
                                children: [
                                  TextFormField(
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                  )
                                ],
                              )),
                              const SizedBox(height: 20),
                              Form(
                                  child: Column(
                                children: [
                                  TextFormField(
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                  )
                                ],
                              )),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                child: const Text('Update Info'),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.edit))
        ],
      ),
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
                              child: CachedNetworkImage(
                                imageUrl: widget.video.thumbnail!,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
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
                              // child: Image.asset(widget.videoThumbnail),
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
                        Text(widget.video.title!),
                        Text(timeAgo(widget.video.date!)),
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
                      child: Text('Vidoe Title : ${widget.video.title}'),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text('Uploaded On : ${widget.video.date}'),
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                            'Artist : ${widget.video.artistName!.join(', ')}')),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text('Tags : ${widget.video.tags!.join(', ')}')),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Align(
              //     alignment: Alignment.bottomLeft,
              //     child: Column(
              //       children: [
              //         const Align(
              //             alignment: Alignment.centerLeft,
              //             child: Text(
              //               'Suggested Video',
              //             )),
              //         const SizedBox(height: 10),
              //         SizedBox(
              //             height: 100,
              //             width: MediaQuery.of(context).size.width,
              //             child: ListView(
              //               scrollDirection: Axis.horizontal,
              //               // padding: EdgeInsets.all(10),

              //               children: [
              //                 AspectRatio(
              //                   aspectRatio: 16 / 9,
              //                   child: Container(
              //                     color: Colors.amber,
              //                   ),
              //                 ),
              //                 const SizedBox(width: 10),
              //                 AspectRatio(
              //                   aspectRatio: 16 / 9,
              //                   child: Container(
              //                     color: Colors.amber,
              //                   ),
              //                 ),
              //                 const SizedBox(width: 10),
              //                 AspectRatio(
              //                   aspectRatio: 16 / 9,
              //                   child: Container(
              //                     color: Colors.amber,
              //                   ),
              //                 ),
              //                 const SizedBox(width: 10),
              //                 AspectRatio(
              //                   aspectRatio: 16 / 9,
              //                   child: Container(
              //                     color: Colors.amber,
              //                   ),
              //                 ),
              //                 const SizedBox(width: 10),
              //                 AspectRatio(
              //                   aspectRatio: 16 / 9,
              //                   child: Container(
              //                     color: Colors.amber,
              //                   ),
              //                 ),
              //                 const SizedBox(width: 10),
              //                 AspectRatio(
              //                   aspectRatio: 16 / 9,
              //                   child: Container(
              //                     color: Colors.amber,
              //                   ),
              //                 ),
              //                 const SizedBox(width: 10),
              //                 AspectRatio(
              //                   aspectRatio: 16 / 9,
              //                   child: Container(
              //                     color: Colors.amber,
              //                   ),
              //                 ),
              //                 const SizedBox(width: 10),
              //               ],
              //             ))
              //       ],
              //     ))
            ],
          ),
        ),
      ),
    );
  }
}
