import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:videostream/features/home/presentation/cubit/upload_status_cubit.dart';

import 'package:videostream/features/home/presentation/widget/videodisplay.dart';
import 'package:videostream/core/resource/secrets.dart';
import 'package:videostream/service_locator/injection_container.dart';

import '../bloc/video_bloc.dart';
import '../bloc/video_event.dart';
import '../bloc/video_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoScreen extends StatefulWidget {
  final ScrollController scrollController;
  const VideoScreen({
    super.key,
    required this.scrollController,
  });

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoBloc videoBloc;
  @override
  void initState() {
    videoBloc = context.read<VideoBloc>();
    videoBloc.add(FetchVideosEvent(page: 0));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool loading = true;
    ValueNotifier currentLabel = ValueNotifier('');
    ValueNotifier selectedLabel = ValueNotifier('All');
    Widget buildCategoryChip(BuildContext context, String label) {
      return BlocBuilder<VideoBloc, VideoState>(
        builder: (context, state) {
          return ValueListenableBuilder(
              valueListenable: selectedLabel,
              builder: (context, value, child) {
                return GestureDetector(
                  onTap: () {
                    selectedLabel.value = label;
                    videoBloc
                        .add(FilterVideosEvent(label == "All" ? null : label));
                    // context
                    //     .read<VideoBloc>()
                    //     .add(ChangeCategoryEvent(label.toLowerCase()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedLabel.value == label
                            ? Colors.white
                            : const Color(0xff282828),
                        border: Border.all(
                            color: selectedLabel.value == label
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
                              color: selectedLabel.value == label
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              });
        },
      );
    }

    return Scaffold(
      body: Center(
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent) {
              videoBloc.add(FetchVideosEvent(
                  page: videoBloc.currentPage + 1,
                  filterTag: videoBloc.currentFilter));
            }
            return false;
          },
          child: CustomScrollView(
            controller: widget.scrollController,
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xff141218),
                centerTitle: true,
                title: Text(
                  'Stream',
                  style: GoogleFonts.getFont('Dancing Script',
                      fontWeight: FontWeight.w900, fontSize: 30),
                ),
                actions: [
                  BlocProvider(
                    create: (context) {
                      final cubit = getIt<UploadStatusCubit>();
                      cubit
                          .onUploadStatus(); // Fetch the status when the widget is created
                      return cubit;
                    },
                    child: BlocBuilder<UploadStatusCubit, UploadStatusState>(
                      builder: (context, state) {
                        if (state is UploadStatusLoading) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: PhosphorIcon(
                              PhosphorIcons.plugs(),
                              color: Colors.red[300],
                            ),
                          );
                        }
                        if (state is UploadStatusLoaded) {
                          return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: PhosphorIcon(
                                PhosphorIcons.plugsConnected(),
                                color: Colors.green[300],
                              ));
                        }
                        if (state is UploadStatusError) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: PhosphorIcon(
                              PhosphorIcons.warning(),
                              color: Colors.yellow[300],
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: PhosphorIcon(
                            PhosphorIcons.plugs(),
                            color: Colors.red[300],
                          ),
                        );
                      },
                    ),
                  )
                ],
                floating: true,
                snap: true,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(55),
                  child: ValueListenableBuilder(
                      valueListenable: currentLabel,
                      builder: (context, value, child) {
                        return Column(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              width: MediaQuery.of(context).size.width,
                              height: 35,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: actualData.map(
                                  (item) {
                                    return buildCategoryChip(context, item);
                                  },
                                ).toList(),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      }),
                ),
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<VideoBloc, VideoState>(
                  builder: (context, state) {
                    if (state is VideoLoading) {
                      return Center(
                          child: Skeletonizer(
                        enabled: loading,
                        child: ListView.builder(
                          itemCount: 3,
                          padding: const EdgeInsets.all(0),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Image.asset(
                                      fit: BoxFit.cover,
                                      'assets/logo.jpeg',
                                    ),
                                  )),
                              subtitle: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('timeAgo(widget.video.date!)'),
                                  Text('Time 00:00'),
                                ],
                              ),
                            );
                          },
                        ),
                      ));
                    } else if (state is VideoLoaded) {
                      if (state.videos.isEmpty) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                              child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PhosphorIcon(
                                  PhosphorIcons.smileyXEyes(),
                                  color: Colors.deepPurpleAccent,
                                  size: 100,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Nothing to see here',
                                  style: GoogleFonts.getFont('Roboto',
                                      fontSize: 25),
                                )
                              ],
                            ),
                          )),
                        );
                      }

                      return Column(
                        children: [
                          // Card(
                          //   child: ListTile(
                          //     title: const Text('Uploading Video'),
                          //     subtitle: Container(
                          //       height: 3,
                          //       decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(10),
                          //           color: Colors.amber),
                          //     ),
                          //   ),
                          // ),
                          ListView.builder(
                            padding: const EdgeInsets.all(0),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.videos.length +
                                (state.hasMoreVideos ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == state.videos.length) {
                                return Center(
                                    child: Skeletonizer(
                                  enabled: loading,
                                  child: ListView.builder(
                                    itemCount: 1,
                                    padding: const EdgeInsets.all(0),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: AspectRatio(
                                              aspectRatio: 16 / 9,
                                              child: Image.asset(
                                                fit: BoxFit.cover,
                                                'assets/logo.jpeg',
                                              ),
                                            )),
                                        subtitle: const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('timeAgo(widget.video.date!)'),
                                            Text('Time 00:00'),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ));
                              }
                              final video = state.videos[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: VideoPlayerWithButton(video: video),
                              );
                            },
                          ),
                        ],
                      );
                    } else if (state is VideoError) {
                      return Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 250),
                            PhosphorIcon(PhosphorIcons.networkSlash(),
                                size: 40),
                            const SizedBox(height: 20),
                            const Text(
                              'Error while fetching data',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Center(
                          child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PhosphorIcon(
                              PhosphorIcons.smileyXEyes(),
                              color: Colors.deepPurpleAccent,
                              size: 100,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Nothing to see here',
                              style:
                                  GoogleFonts.getFont('Roboto', fontSize: 25),
                            )
                          ],
                        ),
                      )),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
