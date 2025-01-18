import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:videostream/multi_use_widget.dart';
import 'package:videostream/screen/stardetails.dart';

class Star extends StatefulWidget {
  const Star({super.key});

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

  @override
  void initState() {
    hiveToLocal();
    super.initState();
  }

  @override
  void dispose() {
    box.close();
    super.dispose();
  }

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
            //       try {
            //         final f = await collectionVideo(collectionName: 'jav');
            //         log(f.toString());
            //       } catch (e) {
            //         log(e.toString());
            //       }
            //       // log('button press');
            //       // log('function called');
            //       // try {
            //       //   log(testarray.toString());
            //       //   for (var element in testarray) {
            //       //     if (element[2] != await totoalVideo(element[1])) {
            //       //       element[2] = await totoalVideo(element[1]);
            //       //     }
            //       //   }
            //       //   log(testarray.toString());
            //       // } catch (e) {
            //       //   log('check update :- $e');
            //       // }
            //       // final w = await totoalVideo('masterbating');
            //       // log(w.toString());

            //       // log(number);
            //       // numberOfVide('jav');
            //       // log(featuringName.toString());
            //     },
            //     child: Text('data')),
            IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(builder:
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
                                                      BorderRadius.circular(10),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                          final number =
                                              await totoalVideo(starName.text);
                                          featuringName.add([
                                            profielPhoto?.path ?? '',
                                            starName.text,
                                            number,
                                          ]);
                                          await box.put(
                                              'featuringList', featuringName);
                                          setState(() {});
                                          starName.clear();
                                          profielPhoto = null;
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Add',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  );
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: featuringName.isEmpty
            ? Center(
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
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisExtent: 380,
                  childAspectRatio: 9 / 16,
                  crossAxisCount: 2,
                ),
                // itemCount: featuringName.length,
                itemCount: featuringName.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StarDetail(
                            collectionName: featuringName[index][1],
                            collectionImage: featuringName[index][0],
                          ),
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
                                child: Image.file(
                                  File(featuringName[index][0]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: Text(
                              featuringName[index][1],
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 3),
                            child: Text('${featuringName[index][2]} Videos'),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ));
  }
}
