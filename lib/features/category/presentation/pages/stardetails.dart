import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:videostream/features/category/presentation/cubit/category_video_cubit.dart';
import 'package:videostream/features/home/presentation/widget/videodisplay.dart';
import 'package:videostream/service_locator/injection_container.dart';

class StarDetail extends StatelessWidget {
  final String collectionName;
  

  const StarDetail({
    super.key,
    required this.collectionName,
  });

  final _loading = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CategoryVideoCubit>()
        ..onFetchCategoryVideo(collectionName),
      child: Scaffold(
        appBar: AppBar(
          title: Text(collectionName),
        ),
        body: BlocBuilder<CategoryVideoCubit, CategoryVideoState>(
          builder: (context, state) {
            if (state is CategoryVideoLoding) {
              return Center(
                  child: Skeletonizer(
                enabled: _loading,
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
            }
            if (state is CategoryVideoError) {
              return Center(
                child: Column(
                  children: [
                    const SizedBox(height: 250),
                    PhosphorIcon(PhosphorIcons.networkSlash(), size: 40),
                    const SizedBox(height: 20),
                    const Text(
                      'Error while fetching data',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }
            if (state is CategoryVideoLoaded) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      //     crossAxisCount: 2, mainAxisExtent: 230),
                      padding: const EdgeInsets.all(0),
                      shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.categoriesVideo.length,
                      itemBuilder: (context, index) {
                        final video = state.categoriesVideo[index];
                        return VideoPlayerWithButton(
                          video: video,
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return Center(
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
                    style: GoogleFonts.getFont('Roboto', fontSize: 25),
                  )
                ],
              ),
            ));
          },
        ),
      ),
    );
  }
}
