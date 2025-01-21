// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

import 'package:videostream/multi_use_widget.dart';
import 'package:videostream/screen/stardetails.dart';
import 'package:videostream/secrets.dart';

class Star extends StatefulWidget {
  String password;
  Star({
    Key? key,
    required this.password,
  }) : super(key: key);

  @override
  State<Star> createState() => _StarState();
}

class _StarState extends State<Star> {
  TextEditingController starName = TextEditingController();
  File? profielPhoto;
  Image? _thumbnail;
  List<List> featuringName = List<List>.empty(growable: true);
  var box;

  hiveToLocal() async {
    List updateValue = [];
    box = await Hive.openBox<List>('featuringList');
    if (box.isNotEmpty) {
      for (var element in box.get('featuringList')) {
        updateValue.add(element);
      }
      try {
        for (var element in updateValue) {
          if (element[2] != await totoalVideo(element[1])) {
            element[2] = await totoalVideo(element[1]);
          }
        }
        for (var element in updateValue) {
          featuringName.add(element);
        }

        // log(featuringName.toString());
      } catch (e) {
        log('check update :- $e');
      }
      setState(() {});
    }
  }

  imagePicker2() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      // Get the path of the selected video file
      String? filePath = result.files.single.path;

      if (filePath != null) {
        setState(() {
          profielPhoto = File(filePath);
        });
      }
      //   setState(() {
      //   if (thumbnailPath != null) {
      //     _thumbnail = Image.file(File(profielPhoto!.path));
      //     _thumbnailPath = thumbnailPath.path;
      //   }
      // });
    }
  }

  Future<int> totoalVideo(String collectionName) async {
    var db = mongo.Db('mongodb://192.168.1.114:27017/stream');
    await db.open();
    final streamdb = db.collection('allVideoData');
    if (collectionName == 'shemale') {
      final result = await streamdb.count({
        {
          'man': {
            r'$regex': true,
          }
        },
      });
      await db.close();
      return result;
    } else {
      final result = await streamdb.count({
        r'$or': [
          {
            'title': {
              r'$regex': collectionName,
              r'$options': "i",
            }
          },
          {
            'artistName': {
              r'$regex': collectionName,
              r'$options': "i",
            }
          },
          {
            'tags': {
              r'$regex': collectionName,
              r'$options': "i",
            }
          },
        ]
      });
      await db.close();
      return result;
    }
  }

  void addNewData({
    required String starName,
    required String starLink,
    required int totalVideo,
  }) {
    Map<String, dynamic> newVideo = {
      "title": starName,
      "starLink": "http://192.168.1.114/videos/star/$starLink",
      "totalVideo": totalVideo,
    };

    updateVideoJson(newVideo, 'starData');
  }

  // @override
  // void initState() {
  //   hiveToLocal();
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   box.close();
  //   super.dispose();
  // }

  List testarray = [
    ['photo', 'jav', 23],
    ['photo2', 'indian', 24]
  ];
  checkAndUpdate() {
    log('function called');
    try {
      log(testarray.toString());
      for (var element in testarray) {
        if (element[2] != totoalVideo(element[1])) {
          element[2] = totoalVideo(element[1]);
        }
      }
      log(testarray.toString());
    } catch (e) {
      log('check update :- $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Featuring'),
          centerTitle: true,
          actions: [
            // ElevatedButton(
            //     onPressed: () async {
            //       // try {
            //       //   final f = await collectionVideo(collectionName: 'jav');
            //       //   log(f.toString());
            //       // } catch (e) {
            //       //   log(e.toString());
            //       // }
            //       //       // log('button press');
            //       //       // log('function called');
            //       //       // try {
            //       //       //   log(testarray.toString());
            //       //       //   for (var element in testarray) {
            //       //       //     if (element[2] != await totoalVideo(element[1])) {
            //       //       //       element[2] = await totoalVideo(element[1]);
            //       //       //     }
            //       //       //   }
            //       //       //   log(testarray.toString());
            //       //       // } catch (e) {
            //       //       //   log('check update :- $e');
            //       //       // }
            //       //       // final w = await totoalVideo('masterbating');
            //       //       // log(w.toString());

            //       //       // log(number);
            //       //       // numberOfVide('jav');
            //       //       // log(featuringName.toString());
            //     },
            //     child: Text('data')),

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
                        child: StatefulBuilder(builder:
                            (BuildContext context, StateSetter modalSetState) {
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
                                      child: GestureDetector(
                                        onTap: () async {
                                          await imagePicker2();
                                          modalSetState(() {});
                                        },
                                        child: profielPhoto != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.file(
                                                  File(profielPhoto!.path),
                                                  fit: BoxFit.cover,
                                                ))
                                            : _thumbnail ??
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 2,
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: const Center(
                                                    child: PhosphorIcon(
                                                        PhosphorIconsBold
                                                            .cloudArrowUp),
                                                  ),
                                                ),
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
                                            final number = await totoalVideo(
                                                starName.text);
                                            await uploadImage(
                                                profielPhoto!, 'star');
                                            addNewData(
                                                starName: starName.text,
                                                starLink: profielPhoto!.path
                                                    .split('/')
                                                    .last
                                                    .trim(),
                                                totalVideo: number);
                                            // featuringName.add([
                                            //   profielPhoto?.path ?? '',
                                            //   starName.text,
                                            //   number,
                                            // ]);
                                            // await box.put(
                                            //     'featuringList', featuringName);
                                            setState(() {});
                                            starName.clear();
                                            profielPhoto = null;
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'Add',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: widget.password == password
              ? videoData(databaseName: 'starData')
              : videoData(databaseName: 'testData'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SizedBox(height: 250),
                    CircularProgressIndicator(),
                  ],
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.cellSignalX(),
                      color: Colors.deepPurpleAccent,
                      size: 100,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Error while fetching data',
                      style: GoogleFonts.getFont('Roboto', fontSize: 25),
                    )
                  ],
                ),
              );
            }

            final data = snapshot.data! as List<dynamic>;
            List<StarData> videos = [];
            for (var value in data) {
              videos.add(StarData(
                title: value['title'],
                link: value['starLink'],
                totalVideos: value['totalVideo'],
              ));
            }

            if (!snapshot.hasData || videos.isEmpty) {
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisExtent: 380,
                childAspectRatio: 9 / 16,
                crossAxisCount: 2,
              ),
              // itemCount: featuringName.length,
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final stardata = videos[index];

                return GestureDetector(
                  // onTap: () {
                  //   log(videos.toString());
                  // },
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StarDetail(
                            collectionName: stardata.title,
                            collectionImage: stardata.link),
                      )),
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
                                imageUrl: stardata.link,
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
                            stardata.title,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 3),
                          child: Text('${stardata.totalVideos} Videos'),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ));
  }
}
