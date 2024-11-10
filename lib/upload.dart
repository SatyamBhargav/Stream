// import 'dart:developer';
// import 'dart:io';

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:videostream/multi_use_widget.dart';

// class Upload extends StatefulWidget {
//   const Upload({super.key});

//   @override
//   State<Upload> createState() => _UploadState();
// }

// class _UploadState extends State<Upload> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         child: Column(
//           children: [
//             AspectRatio(
//                 aspectRatio: 16 / 9,
//                 child: GestureDetector(
//                   onTap: () async {
//                     FilePickerResult? result =
//                         await FilePicker.platform.pickFiles();

//                     if (result != null) {
//                       File file = File(result.files.single.path!);
//                       log(file.path);
//                     } else {
//                       // User canceled the picker
//                     }
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                         color: Colors.grey,
//                         borderRadius: BorderRadius.circular(10)),
//                     child: Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(
//                             Icons.video_camera_back_outlined,
//                             size: 50,
//                           ),
//                           formatedText(
//                               text: 'Select a video',
//                               fontFamily: 'Roboto',
//                               fontweight: FontWeight.bold)
//                         ],
//                       ),
//                     ),
//                   ),
//                 )),
//             Form(
//                 child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   decoration: InputDecoration(
//                       label: const Text('Title'),
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10))),
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   decoration: InputDecoration(
//                       label: const Text('Artist Name'),
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10))),
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   decoration: InputDecoration(
//                       label: const Text('Tags'),
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10))),
//                 ),
//               ],
//             ))
//           ],
//         ),
//       ),
//     );
//   }
// }
//****************************** working without progress inidcator *********************************************** */
// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
// // import 'dart:math';

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
// import 'package:http/http.dart' as http;

// class Upload extends StatefulWidget {
//   const Upload({super.key});

//   @override
//   State<Upload> createState() => _UploadState();
// }

// class _UploadState extends State<Upload> {
//   File? _videoFile;
//   Image? _thumbnail;

//   Future<void> _selectVideo() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();

//     if (result != null) {
//       _videoFile = File(result.files.single.path!);

//       // Generate a random thumbnail from the video
//       await _generateThumbnail();
//     }
//   }

//   Future<void> _generateThumbnail() async {
//     // Get the duration of the video (optional)
//     final videoDuration = await VideoThumbnail.thumbnailFile(
//       video: _videoFile!.path,
//       thumbnailPath: (await getTemporaryDirectory()).path,
//       imageFormat: ImageFormat.JPEG,
//       maxWidth: 128, // specify the width of the thumbnail
//       quality: 75,
//     );

//     setState(() {
//       if (videoDuration != null) {
//         _thumbnail = Image.file(File(videoDuration));
//       }
//     });
//   }

//   Future<void> uploadVideo(File videoFile) async {
//     final uri = Uri.parse(
//         'http://192.168.1.114:5000/upload'); // Ensure this matches the upload endpoint

//     // Create multipart request
//     final request = http.MultipartRequest('POST', uri)
//       ..files.add(await http.MultipartFile.fromPath(
//         'file',
//         videoFile.path,
//         filename: basename(videoFile.path),
//       ));

//     // Send request
//     final response = await request.send();

//     if (response.statusCode == 200) {
//       print('Video uploaded successfully');
//     } else {
//       print('Failed to upload video. Status code: ${response.statusCode}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         child: Column(
//           children: [
//             AspectRatio(
//               aspectRatio: 16 / 9,
//               child: GestureDetector(
//                 onTap: _selectVideo,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Center(
//                     child: _thumbnail ??
//                         const Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.video_camera_back_outlined,
//                               size: 50,
//                             ),
//                             Text(
//                               'Select a video',
//                               style: TextStyle(
//                                 fontFamily: 'Roboto',
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                   ),
//                 ),
//               ),
//             ),
//             Form(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       label: const Text('Title'),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       label: const Text('Artist Name'),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       label: const Text('Tags'),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   ElevatedButton(
//                       onPressed: () {
//                         uploadVideo(_videoFile!);
//                       },
//                       child: const Text('upload'))
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:http/http.dart' as http;
import 'package:videostream/multi_use_widget.dart';

class Upload extends StatefulWidget {
  const Upload({super.key});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File? _videoFile;
  File? _thumbnailFile;
  Image? _thumbnail;
  bool _isUploading = false; // Flag to track upload progress
  TextEditingController title = TextEditingController();
  TextEditingController artistName = TextEditingController();
  TextEditingController tags = TextEditingController();
  String? _thumbnailPath;
  String? videoDuration;

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

  Future<void> _selectVideo() async {
    // Open the file picker to select a video file
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      // Get the path of the selected video file
      String? filePath = result.files.single.path;

      if (filePath != null) {
        _videoFile = File(filePath);

        // Generate a thumbnail from the selected video
        await _generateThumbnail();
      } else {
        // Handle the case where the file path is null
        if (kDebugMode) {
          print("No valid file path found.");
        }
      }
    } else {
      // Handle the case where no file was selected
      if (kDebugMode) {
        print("No file selected.");
      }
    }
  }

  Future<void> _generateThumbnail() async {
    // Create a VideoPlayerController to get the video's dimensions
    final controller = VideoPlayerController.file(_videoFile!);
    await controller.initialize();
    final videoLength = controller.value.duration;
    videoDuration = formatDuration(videoLength);
    final videoWidth = controller.value.size.width;
    final videoHeight = controller.value.size.height;

    // Set the thumbnail size based on the video's aspect ratio
    int maxWidth, maxHeight;
    if (videoWidth > videoHeight) {
      // Landscape
      maxWidth = 428; // You can adjust this value as needed
      maxHeight =
          (maxWidth * videoHeight ~/ videoWidth); // Maintain aspect ratio
    } else {
      // Portrait
      maxHeight = 228; // You can adjust this value as needed
      maxWidth =
          (maxHeight * videoWidth ~/ videoHeight); // Maintain aspect ratio
    }

    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: _videoFile!.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: maxWidth,
      maxHeight: maxHeight, // Use the calculated max height
      quality: 75,
    );

    setState(() {
      if (thumbnailPath != null) {
        _thumbnail = Image.file(File(thumbnailPath.path));
        _thumbnailPath = thumbnailPath.path;
      }
    });

    // Dispose the controller after use
    controller.dispose();
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

  Future<void> updateThumbnail(File videoFile) async {
    final uri = Uri.parse('http://192.168.1.114:5000/thumbnail');

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
          print('Thumbnail uploaded successfully');
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

  Future<void> updateVideoJson(Map<String, dynamic> newVideoData) async {
    const url =
        'http://192.168.1.114:5000/update_json'; // Change this to your server's address

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(newVideoData),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        if (kDebugMode) {
          print('Json updated successfully');
        }
      } else {
        if (kDebugMode) {
          print('Error: ${responseData['message']}');
        }
      }
    } else {
      if (kDebugMode) {
        print('Request failed with status: ${response.statusCode}');
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
          : "http://192.168.1.114/videos/thumbnail/${_thumbnailPath!.split('/').last}",
      "videoLike": 5,
      "videoDislike": 2,
      "artistName": artistName,
      "date": date,
      "duration": videoDuration,
      "trans": false,
      "tags": tags
    };

    updateVideoJson(newVideo);
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
              AspectRatio(
                aspectRatio: 16 / 9,
                child: GestureDetector(
                  onTap: _selectVideo,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      // child: _thumbnail ??
                      child: _thumbnailFile != null
                          ? Image.file(File(_thumbnailFile!.path))
                          : _thumbnail ??
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 50,
                                  ),
                                  Text(
                                    'Select a video',
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
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.image),
                    TextButton(
                        onPressed: _videoFile == null
                            ? null
                            : () {
                                _customThumbnail();
                              },
                        child: const Text('Custom thumbnail')),
                  ],
                ),
              ),
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: title,
                      decoration: InputDecoration(
                        label: const Text('Title'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: artistName,
                      decoration: InputDecoration(
                        label: const Text('Artist Name'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
                            child: ElevatedButton(
                              onPressed: () async {
                                // log(tags.text.split(",").toList().toString());
                                // log(_thumbnailFile!.path);
                                setState(() {
                                  _isUploading = true;
                                });
                                //**************** Vidoe Upload ***************** */
                                if (_videoFile != null) {
                                  await uploadVideo(_videoFile!);
                                } else {
                                  // Handle case when no file is selected
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Please select a video first.'),
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
                                    ? await updateThumbnail(
                                        File(_thumbnailFile!.path))
                                    : await updateThumbnail(
                                        File(_thumbnailPath!));
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
                                      _videoFile!.path.split('/').last.trim(),
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
                              child: const Text('Upload'),
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
