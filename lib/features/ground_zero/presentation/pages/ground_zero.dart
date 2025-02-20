import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:videostream/features/ground_zero/presentation/bloc/ground_zero_bloc.dart';
import 'package:videostream/features/ground_zero/presentation/cubit/update_app_cubit.dart';
import 'package:videostream/features/ground_zero/presentation/widget/update_ui.dart';
import 'package:videostream/features/home/presentation/pages/video_screen.dart';
import 'package:videostream/features/upload/presentation/pages/upload.dart';
import 'package:videostream/features/category/presentation/pages/star.dart';

class GroundZero extends StatefulWidget {
  const GroundZero({super.key});

  @override
  State<GroundZero> createState() => _GroundZeroState();
}

class _GroundZeroState extends State<GroundZero>
    with SingleTickerProviderStateMixin {
  final PageController pageController = PageController(initialPage: 0);
  ValueNotifier<int> selectedIndex = ValueNotifier(0);
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    context.read<UpdateAppCubit>().onUploadStatus();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        _animationController.forward(); // Hide bottom section
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        _animationController.reverse(); // Show bottom section
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateAppCubit, UpdateAppState>(
      listener: (context, state) {
        UpdateUi(context, state);
      },
      child: Scaffold(
        body: Stack(
          children: [
            BlocListener<GroundZeroBloc, GroundZeroState>(
              listener: (context, state) {
                if (state is GroundZeroError) {
                  Fluttertoast.showToast(msg: state.message);
                }
                if (state is GroundZeroLoaded) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Upload(
                        thumbnail: state.video.thumbnail,
                        videoFile: state.video.videoFile,
                        thumbnailPath: state.video.thumbnailPath,
                        videoDuration: state.video.videoDuration,
                      ),
                    ),
                  );
                }
              },
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: pageController,
                onPageChanged: (index) {
                  selectedIndex.value = index;
                },
                children: [
                  VideoScreen(scrollController: _scrollController),
                  // VideoScreen(), // Pass controller
                  // VideoListScreen(),
                  Upload(),
                  Star(password: ''),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 100 * _animation.value),
                  child: ValueListenableBuilder(
                      valueListenable: selectedIndex,
                      builder: (context, value, child) {
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              height: 50,
                              child: Center(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (selectedIndex.value != 0) {
                                          selectedIndex.value = 0;
                                          pageController.jumpToPage(0);
                                        }
                                      },
                                      icon: selectedIndex.value == 0
                                          ? const PhosphorIcon(
                                              PhosphorIconsFill.house,
                                              size: 30,
                                            )
                                          : PhosphorIcon(
                                              PhosphorIcons.house(),
                                              size: 30,
                                            ),
                                    ),
                                    BlocBuilder<GroundZeroBloc,
                                        GroundZeroState>(
                                      builder: (context, state) {
                                        if (state is GroundZeroLoading) {
                                          return const SizedBox(
                                            height: 25,
                                            width: 25,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          );
                                        }

                                        return IconButton(
                                          onPressed: () async {
                                            // selectedIndex.value = 1;
                                            context
                                                .read<GroundZeroBloc>()
                                                .add(FetchVideo());
                                          },
                                          icon: selectedIndex.value == 1
                                              ? const PhosphorIcon(
                                                  PhosphorIconsFill.plusCircle,
                                                  size: 30,
                                                )
                                              : PhosphorIcon(
                                                  PhosphorIcons.plusCircle(),
                                                  size: 30,
                                                ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        if (selectedIndex.value != 2) {
                                          selectedIndex.value = 2;
                                          pageController.jumpToPage(2);
                                        }
                                      },
                                      icon: selectedIndex.value == 2
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
                          ),
                        );
                      }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
