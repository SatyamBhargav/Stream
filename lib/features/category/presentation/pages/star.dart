// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:videostream/features/category/presentation/bloc/category_bloc.dart';
import 'package:videostream/features/category/presentation/bloc/category_state.dart';
import 'package:videostream/features/category/presentation/cubit/upload_category_data_cubit.dart';
import 'package:videostream/features/category/presentation/pages/stardetails.dart';

// ignore: must_be_immutable
class Star extends StatelessWidget {
  final ScrollController scrollController;

  Star({
    super.key,
    required this.scrollController,
  });

  TextEditingController starName = TextEditingController();

  final bool _loading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Category'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context)
                              .viewInsets
                              .bottom, // Adjust based on keyboard height
                        ),
                        child: BlocBuilder<UploadCategoryDataCubit,
                            UploadCategoryDataState>(
                          builder: (context, state) {
                            return Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 300,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: AspectRatio(
                                        aspectRatio: 9 / 16,
                                        child: BlocBuilder<
                                            UploadCategoryDataCubit,
                                            UploadCategoryDataState>(
                                          builder: (context, state) {
                                            if (state
                                                is UploadCategoryImageDataLoading) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                            if (state
                                                is UploadCategoryImageDataLoaded) {
                                              return ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.file(
                                                    File(state.imageData),
                                                    fit: BoxFit.cover,
                                                  ));
                                            }
                                            if (state
                                                is UploadCategoryImageDataError) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 2,
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Center(
                                                  child: PhosphorIcon(
                                                      PhosphorIconsBold
                                                          .imageBroken),
                                                ),
                                              );
                                            }
                                            return GestureDetector(
                                              onTap: () async {
                                                // await imagePicker2();
                                                // modalSetState(() {});
                                                context
                                                    .read<
                                                        UploadCategoryDataCubit>()
                                                    .onUpdateCategoryImage();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 2,
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Center(
                                                  child: PhosphorIcon(
                                                      PhosphorIconsBold
                                                          .cloudArrowUp),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    // Right-side column
                                    Expanded(
                                      flex:
                                          3, // Adjust flex to control width proportion
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextField(
                                            controller: starName,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              hintText: 'Name',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.deepPurpleAccent,
                                            ),
                                            onPressed: () async {
                                              context
                                                  .read<
                                                      UploadCategoryDataCubit>()
                                                  .onUploadCategoryImage(
                                                      false, true);
                                              context
                                                  .read<
                                                      UploadCategoryDataCubit>()
                                                  .onUploadCategoryData(
                                                      starName.text);
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Add',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
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
            if (state is CategoryError) {
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
            if (state is CategoryLoaded) {
              if (state.categories.isEmpty) {
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
              }
              return GridView.builder(
                controller: scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisExtent: 380,
                  childAspectRatio: 9 / 16,
                  crossAxisCount: 2,
                ),
                // itemCount: featuringName.length,
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final stardata = state.categories[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StarDetail(
                              collectionName: stardata.categoryName!,
                            ),
                          ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 300,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AspectRatio(
                                aspectRatio: 9 / 16,
                                child: CachedNetworkImage(
                                  imageUrl: stardata.categroyImagePath!,
                                  fit: BoxFit.cover,
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
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: Text(
                              stardata.categoryName!,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child:
                                Text('${stardata.categoryTotalVideo} Videos'),
                          )
                        ],
                      ),
                    ),
                  );
                },
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
        ));
  }
}
