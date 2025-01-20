// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:videostream/multi_use_widget.dart';

class Upload extends StatefulWidget {
  Image? thumbnail;
  String? thumbnailPath;
  String? videoDuration;
  File? videoFile;

  Upload(
      {Key? key,
      this.thumbnail,
      this.thumbnailPath,
      this.videoDuration,
      this.videoFile})
      : super(key: key);

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File? _thumbnailFile;

  bool _isUploading = false; // Flag to track upload progress
  TextEditingController title = TextEditingController();
  TextEditingController artistName = TextEditingController();
  TextEditingController tags = TextEditingController();

  // Future<void> _selectVideo() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();

  //   if (result != null) {
  //     _videoFile = File(result.files.single.path!);

  //     // Generate a random thumbnail from the video
  //     await _generateThumbnail();
  //   }
  // }

  // Future<void> _generateThumbnail() async {
  //   final videoDuration = await VideoThumbnail.thumbnailFile(
  //     video: _videoFile!.path,
  //     thumbnailPath: (await getTemporaryDirectory()).path,
  //     imageFormat: ImageFormat.JPEG,
  //     maxWidth: 128,
  //     quality: 75,
  //   );

  //   setState(() {
  //     if (videoDuration != null) {
  //       _thumbnail = Image.file(File(videoDuration));
  //     }
  //   });
  // }

  _customThumbnail() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      // Get the path of the selected video file
      String? filePath = result.files.single.path;

      if (filePath != null) {
        _thumbnailFile = File(filePath);
      }
      setState(() {});
    }
  }

  Future<void> uploadVideo(File videoFile) async {
    final uri = Uri.parse('http://192.168.1.114:5000/upload');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        videoFile.path,
        filename: basename(videoFile.path),
      ));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Video uploaded successfully');
        }
      } else {
        if (kDebugMode) {
          print('Failed to upload video. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading video: $e');
      }
    }
  }

  void addNewVideo({
    required String videoTitle,
    required String vidoName,
    required List artistName,
    required String date,
    required List tags,
  }) {
    Map<String, dynamic> newVideo = {
      "title": videoTitle,
      "videoLink": "http://192.168.1.114/videos/$vidoName",
      "videoThumbnail": _thumbnailFile != null
          ? "http://192.168.1.114/videos/thumbnail/${_thumbnailFile!.path.split('/').last}"
          : "http://192.168.1.114/videos/thumbnail/${widget.thumbnailPath!.split('/').last}",
      "videoLike": 5,
      "videoDislike": 2,
      "artistName": artistName,
      "date": date,
      "duration": widget.videoDuration,
      "trans": false,
      "tags": tags
    };

    updateVideoJson(newVideo, 'allVideoData');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: GestureDetector(
                      // onTap: _selectVideo,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          // child: _thumbnail ??
                          child: _thumbnailFile != null
                              ? Image.file(File(_thumbnailFile!.path))
                              : widget.thumbnail ??
                                  const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      PhosphorIcon(
                                        PhosphorIconsBold.cloudArrowUp,
                                        size: 50,
                                      ),
                                      // Icon(
                                      //   Icons.cloud_upload_outlined,
                                      //   size: 50,
                                      // ),
                                      Text(
                                        'Upload',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.2),
                      child: IconButton(
                          onPressed: widget. videoFile == null
                              ? null
                              : () {
                                  _customThumbnail();
                                },
                          icon: PhosphorIcon(PhosphorIcons.pencilSimple())),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 10),
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       const Icon(Icons.image),
              //       TextButton(
              //           onPressed: _videoFile == null
              //               ? null
              //               : () {
              //                   _customThumbnail();
              //                 },
              //           child: const Text('Custom thumbnail')),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 20),
              const Divider(),
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      textAlign: TextAlign.center,
                      controller: title,
                      decoration: const InputDecoration(
                        label: Center(child: Text('Title')),
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PhosphorIcon(PhosphorIcons.user()),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            controller: artistName,
                            decoration: const InputDecoration(
                              label: Text('Artist'),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: tags,
                      decoration: InputDecoration(
                        hintText: 'tag1,tag2,tag3',
                        hintStyle: const TextStyle(
                            fontSize: 13,
                            color: Color.fromARGB(255, 96, 96, 96)),
                        label: const Text('Tags'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _isUploading // Check the upload flag
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Center(
                            child: Container(
                              width: 370,
                              height: 45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white),
                                onPressed: () async {
                                  // log(tags.text.split(",").toList().toString());
                                  // log(_thumbnailFile!.path);
                                  setState(() {
                                    _isUploading = true;
                                  });
                                  //**************** Vidoe Upload ***************** */
                                  if (widget.videoFile != null) {
                                    await uploadVideo(widget.videoFile!);
                                  } else {
                                    // Handle case when no file is selected
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please select a video first.'),
                                      ),
                                    );
                                  }
                                  //*********************************************** */

                                  // log(DateFormat('dd/mm/yyyy')
                                  //     .format(DateTime.now())
                                  //     .toString());

                                  // log(_videoFile!.path.split('/').last.trim());
                                  // log(title.text);
                                  // log([artistName.text].toString());
                                  // log(tags.text);
                                  // log(_thumbnailPath!.split('/').last);
                                  _thumbnailFile != null
                                      ? await uploadImage(
                                          File(_thumbnailFile!.path),
                                          'thumbnail',
                                        )
                                      : await uploadImage(
                                          File(widget.thumbnailPath!),
                                          'thumbnail',
                                        );
                                  addNewVideo(
                                    videoTitle: title.text.trim(),
                                    artistName: [artistName.text],
                                    date: DateFormat('dd/MM/yyyy HH:mm')
                                        .format(DateTime.now())
                                        .toString(),
                                    tags: tags.text
                                        .split(',')
                                        .map((item) => item.trim())
                                        .toList(),
                                    vidoName:
                                        widget.videoFile!.path.split('/').last.trim(),
                                  );
                                  setState(() {
                                    _isUploading = false;
                                  });
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(context);
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Uploading complete please refresh'),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Upload',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
