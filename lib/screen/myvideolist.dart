// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:videostream/multi_use_widget.dart';
import 'package:videostream/screen/star.dart';
import 'package:videostream/screen/upload.dart';
import 'package:videostream/secrets.dart';
import 'package:videostream/videoscreen.dart';

class MyVideoList extends StatefulWidget {
  String password;
  MyVideoList({
    Key? key,
    required this.password,
  }) : super(key: key);

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

  Widget buildCategoryChip(String label) {
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
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
      ),
    );
  }

  @override
  void initState() {
    getAppVersion();
    fetchLatestRelease();
    super.initState();
  }

  final PageController pageController = PageController(initialPage: 0);
  late int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //     ElevatedButton(
      //         onPressed: () async {
      //           getAppVersion();
      //         },
      //         child: Text('data'))
      //   ],
      // ),
      // bottomNavigationBar: BottomAppBar(child: ,
      // onTap: (value) {
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const Upload(),
      //       ));
      // },
      // items: [
      //   BottomNavigationBarItem(
      //     label: '',
      //     icon: PhosphorIcon(
      //       PhosphorIcons.plusCircle(),
      //       size: 30,
      //     ),
      //   ),
      //   BottomNavigationBarItem(
      //     label: '',
      //     icon: PhosphorIcon(
      //       PhosphorIcons.fire(),
      //       size: 30,
      //     ),
      //   ),
      // ],
      // )

      bottomNavigationBar: Container(
        // color: Colors.amber,
        height: 80,

        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                    pageController.jumpToPage(0);
                  });
                },
                icon: _selectedIndex == 0
                    ? const PhosphorIcon(
                        PhosphorIconsFill.house,
                        size: 30,
                      )
                    : PhosphorIcon(
                        PhosphorIcons.house(),
                        size: 30,
                      ),
              ),
              IconButton(
                onPressed: () {
                  selectVideo(context);
                  // setState(() {
                  //   _selectedIndex = 1;
                  //   pageController.jumpToPage(1);
                  // });
                },
                icon: _selectedIndex == 1
                    ? const PhosphorIcon(
                        PhosphorIconsFill.plusCircle,
                        size: 30,
                      )
                    : PhosphorIcon(
                        PhosphorIcons.plusCircle(),
                        size: 30,
                      ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2;
                    pageController.jumpToPage(2);
                  });
                },
                icon: _selectedIndex == 2
                    ? const PhosphorIcon(
                        PhosphorIconsFill.fire,
                        size: 30,
                      )
                    : PhosphorIcon(
                        PhosphorIcons.fire(),
                        size: 30,
                      ),
              ),
            ],
          ),
        ),
      ),

      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: [
          Center(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: const Color(0xff141218),
                  centerTitle: true,
                  title: Text(
                    'Stream',
                    style: GoogleFonts.getFont('Dancing Script',
                        fontWeight: FontWeight.w900, fontSize: 30),
                  ),
                  floating: true,
                  snap: true,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(55),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          width: MediaQuery.of(context).size.width,
                          height: 35,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: widget.password == password
                                ? actualData.map(
                                    (item) {
                                      return buildCategoryChip(item);
                                    },
                                  ).toList()
                                : displayData.map(
                                    (item) {
                                      return buildCategoryChip(item);
                                    },
                                  ).toList(),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  // actions: [
                  //   IconButton(
                  //     onPressed: () {
                  //       setState(() {});
                  //     },
                  //     icon: const Icon(Icons.refresh),
                  //   ),
                  //   IconButton(
                  //     onPressed: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => const Upload(),
                  //         ),
                  //       );
                  //     },
                  //     icon: const CircleAvatar(
                  //       radius: 13,
                  //       backgroundColor: Colors.white,
                  //       child: CircleAvatar(
                  //         backgroundColor: Colors.black,
                  //         radius: 12,
                  //         child: Icon(
                  //           Icons.add,
                  //           size: 17,
                  //           color: Colors.white,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ],
                ),
                SliverToBoxAdapter(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: widget.password == password
                        ? videoData(databaseName: 'allVideoData')
                        : videoData(databaseName: 'testVideoData'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Column(
                          children: [
                            SizedBox(height: 250),
                            CircularProgressIndicator(),
                          ],
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Column(
                          children: [
                            const SizedBox(height: 250),
                            PhosphorIcon(
                              PhosphorIcons.networkSlash(),
                              size: 40,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Error while fetching data',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ));
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

                      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
                      videos.sort((a, b) {
                        DateTime dateA = dateFormat.parse(a.date);
                        DateTime dateB = dateFormat.parse(b.date);
                        return dateB.compareTo(dateA);
                      });

                      videos = filterVideosByLabel(videos);

                      if (!snapshot.hasData || videos.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 250),
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
          ),
          Center(
            child: Upload(),
          ),
          Center(
            child: Star(password: widget.password),
          )
        ],
      ),
    );
  }

  String? appVersion;
  ValueNotifier downloadProgressNotifier = ValueNotifier(0);
  ValueNotifier isUpdating = ValueNotifier(false);
  ValueNotifier checkUpdate = ValueNotifier(false);
  final dio = Dio();

  void fetchLatestRelease() async {
    try {
      checkUpdate.value = true;
      final response = await dio.get(
          'https://api.github.com/repos/SatyamBhargav/Stream/releases/latest');
      // log(response.toString());

      if (response.statusCode == 200) {
        final data = response.data;
        final currentAppVersion = await getAppVersion();
        final tagName = data['tag_name'];

        if (tagName != currentAppVersion) {
          await Future.delayed(const Duration(seconds: 2));
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) {
              return SimpleDialog(
                backgroundColor: Colors.transparent,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    width: 300,
                    decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(30)),
                    child: Column(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.info(),
                          size: 35,
                        ),
                        const SizedBox(height: 10),
                        Text('v$tagName',
                            style: const TextStyle(
                              fontSize: 30,
                            )),
                        const SizedBox(height: 10),
                        const Text(
                          'New app version available\nvappVersion',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 45,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(30)),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: TextButton(
                                  onPressed: () {
                                    isUpdating.value = !isUpdating.value;
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Cancle',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  )),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () async {
                                isUpdating.value = !isUpdating.value;

                                if (response.statusCode == 200) {
                                  final data = jsonDecode(response.data);

                                  final downloadUrl =
                                      data['assets'][0]['browser_download_url'];
                                  try {
                                    updateApp(downloadUrl);
                                  } catch (e) {
                                    Fluttertoast.showToast(
                                        msg: "An error occured while updating",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red[200],
                                        textColor: Colors.black,
                                        fontSize: 16.0);
                                  }
                                } else {
                                  log('Failed to fetch latest release. Status code: ${response.statusCode}');
                                }
                              },
                              child: Container(
                                height: 49,
                                width: 100,
                                decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    border: Border.all(
                                      color: Colors.grey[900]!,
                                    ),
                                    borderRadius: BorderRadius.circular(30)),
                                child: AnimatedSwitcher(
                                    duration: const Duration(seconds: 1),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                          opacity: animation, child: child);
                                    },
                                    child: isUpdating.value
                                        ? Text(
                                            "${downloadProgressNotifier.value}%",
                                            style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Update',
                                            key: ValueKey(2),
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600),
                                          )),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          );
        } else {
          log('up-to date');
          // Fluttertoast.showToast(
          //     msg: "App is up-to-date",
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.BOTTOM,
          //     timeInSecForIosWeb: 1,
          //     backgroundColor: Colors.grey[800],
          //     textColor: Colors.white,
          //     fontSize: 16.0);
          checkUpdate.value = false;
        }
      } else {
        log('Failed to fetch latest release. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error while fetching: $e');
    }
  }

  Future<String> getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      String currentVersion = packageInfo.version;

      setState(() {
        appVersion = currentVersion;
      });
      log('Current App Version: $currentVersion');
      return currentVersion;
    } catch (e) {
      log('Failed to get app version: $e');
      setState(() {
        appVersion = 'error';
      });
      return e.toString();
    }
  }

  Future<void> updateApp(String downloadUrl) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/app-update.apk';

      log('Downloading APK to: $filePath');

      Dio dio = Dio();
      await dio.download(downloadUrl, filePath,
          onReceiveProgress: (actualBytes, int totalBytes) {
        downloadProgressNotifier.value =
            (actualBytes / totalBytes * 100).floor();
      });

      log('APK downloaded successfully.');
      isUpdating.value = !isUpdating.value;
      downloadProgressNotifier.value = 0;
      // Step 3: Prompt the user to install the APK
      // final result = await OpenFile.open(filePath);
      // log('OpenFile result: $result');
    } catch (e) {
      log('Error during app update: $e');
    }
  }
}

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
