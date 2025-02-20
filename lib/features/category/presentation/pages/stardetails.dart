import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:videostream/features/category/presentation/cubit/category_video_cubit.dart';
import 'package:videostream/features/home/presentation/widget/videodisplay.dart';
import 'package:videostream/service_locator/injection_container.dart';

class StarDetail extends StatefulWidget {
  final String collectionName;

  const StarDetail({
    super.key,
    required this.collectionName,
  });

  @override
  State<StarDetail> createState() => _StarDetailState();
}

class _StarDetailState extends State<StarDetail> {
  final _loading = true;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CategoryVideoCubit>()
        ..onFetchCategoryVideo(widget.collectionName),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.collectionName),
        ),
        body: BlocBuilder<CategoryVideoCubit, CategoryVideoState>(
          builder: (context, state) {
            if (state is CategoryVideoLoding) {
              return Center(
                  child: Skeletonizer(
                enabled: _loading,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisExtent: 380,
                    childAspectRatio: 9 / 16,
                    crossAxisCount: 2,
                  ),
                  itemCount: 4,
                  padding: const EdgeInsets.all(0),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: SizedBox(
                        height: 300,
                        // width: 10,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AspectRatio(
                              aspectRatio: 9 / 16,
                              child: Image.asset(
                                fit: BoxFit.cover,
                                'assets/logo.jpeg',
                              ),
                            )),
                      ),
                      subtitle: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category name'),
                          Text('10 video'),
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
