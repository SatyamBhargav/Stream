import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:videostream/core/utility/time_manupulator.dart';
import 'package:videostream/features/videoplayer/presentation/bloc/subtitle_bloc.dart';


class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final String title;

  const FullScreenVideoPlayer({
    super.key,
    required this.controller,
    required this.title,
  });

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  bool _isControlsVisible = true;
  Timer? _timer;
  late VoidCallback _listener;
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _startUpdating();
    _listener = () {
      if (mounted) {
        // ✅ Check if widget is still mounted
        context.read<SubtitleBloc>().add(UpdateSubtitle(
              widget.controller.value.position.inSeconds,
            ));
      }
    };

    widget.controller.addListener(_listener);
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
   
    widget.controller.removeListener(_listener);
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
                child: Stack(
                  children: [
                    VideoPlayer(widget.controller),
                    BlocBuilder<SubtitleBloc, SubtitleState>(
                      builder: (context, state) {
                        if (state is SubtitleLoaded &&
                            state.currentSubtitle != null) {
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              color: Colors.black54,
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                state.currentSubtitle!,
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_isControlsVisible) _buildControls(),
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
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.black.withOpacity(0.3),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(widget.controller.value.position),
                style: const TextStyle(color: Colors.white),
              ),
              Expanded(
                child: Slider(
                  value: widget.controller.value.position.inSeconds.toDouble(),
                  min: 0.0,
                  max: widget.controller.value.duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    widget.controller.seekTo(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Text(
                formatDuration(widget.controller.value.duration),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  context.read<SubtitleBloc>().add(FetchSubtitle());
                },
                icon: const Icon(Icons.subtitles_rounded, color: Colors.white),
              ),
              IconButton(
                icon: const Icon(
                  Icons.screen_rotation_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _toggleOrientation,
              ),
            ],
          ),
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
        ],
      ),
    );
  }

  void _startUpdating() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  void _toggleOrientation() {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }
  }
}
