import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:videostream/features/home/domain/entities/video_entity.dart';
import 'package:videostream/core/utility/time_manupulator.dart';
import 'package:videostream/features/videoplayer/presentation/pages/videoplayer.dart';

class VideoPlayerWithButton extends StatefulWidget {
  final VideoEntity video;

  const VideoPlayerWithButton({
    super.key,
    required this.video,
  });

  @override
  // ignore: library_private_types_in_public_api
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
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.video.link!));
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
  }

  // ignore: unused_element
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

        if (currentPosition < duration - const Duration(seconds: 20)) {
          await Future.delayed(const Duration(seconds: 2));
          await _controller!
              .seekTo(currentPosition + const Duration(seconds: 10));
        } else {
          _isSkipping = false;
          _controller!.removeListener(() {});
          _controller!.pause();
          _ispeeking = false;
        }
      }
    });
  }

  ValueNotifier isSelected = ValueNotifier(false);
  ValueNotifier isDeteting = ValueNotifier(false);
  ValueNotifier<List> deletingList = ValueNotifier<List>([]);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // if (deletingList.value.isNotEmpty) {
        //   isSelected.value = !isSelected.value;
        // } else {
        //   _controller?.pause();
        //   setState(() {
        //     _ispeeking = false;
        //     _isInitialized = false;
        //   });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              video: widget.video,
            ),
          ),
        );
      },
      onLongPressStart: (_) {
        // log(widget.videoUrl);
        isSelected.value = !isSelected.value;
        // isDeteting.value = true;
        if (deletingList.value.contains(widget.video.link)) {
          deletingList.value.remove(widget.video.link);
        } else {
          deletingList.value.add(widget.video.link);
        }
        // log(isSelected.value.toString());
      },
      child: ValueListenableBuilder(
          valueListenable: isSelected,
          builder: (context, selected, child) {
            return Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: isSelected.value == true
                          ? Colors.white
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Stack(
                    children: [
                      _isInitialized && _ispeeking
                          ? Container(
                              decoration: BoxDecoration(
                                  color: Colors.black,
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
                                      imageUrl: widget.video.thumbnail!,
                                      placeholder: (context, url) =>
                                          Shimmer.fromColors(
                                        baseColor: Colors.grey[900]!,
                                        highlightColor: Colors.grey[600]!,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[700],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                              Icons.broken_image_outlined),
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
                                    await Future.delayed(
                                        const Duration(seconds: 1));
                                    _ispeeking = true;
                                  }
                                  _startSkipPlay();
                                },
                                icon: _isInitialized
                                    ? const SizedBox.shrink()
                                    : const Icon(
                                        Icons.remove_red_eye_outlined)),
                      ),
                      isSelected.value == true
                          ? Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Checkbox(
                                activeColor: Colors.white,
                                shape: const CircleBorder(),
                                value: true,
                                onChanged: (value) {},
                              ),
                            )
                          : const SizedBox()
                    ],
                  ),
                  ListTile(
                    title: Text(
                      widget.video.title!,
                      textAlign: TextAlign.center,
                    ),
                    // trailing: Text(
                    //   widget.video.duration!,
                    //   style: const TextStyle(fontSize: 15),
                    // ),

                    subtitle: Text(
                      timeAgo(widget.video.date!),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
