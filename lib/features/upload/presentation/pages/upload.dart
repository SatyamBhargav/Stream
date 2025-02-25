// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:videostream/features/upload/domain/entities/videos.dart';
import 'package:videostream/features/upload/presentation/bloc/upload_bloc.dart';

// ignore: must_be_immutable
class Upload extends StatefulWidget {
  Image? thumbnail;
  String? thumbnailPath;
  String? videoDuration;
  File? videoFile;

  Upload(
      {super.key,
      this.thumbnail,
      this.thumbnailPath,
      this.videoDuration,
      this.videoFile});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File? _thumbnailFile;

  TextEditingController title = TextEditingController();
  TextEditingController artistName = TextEditingController();
  TextEditingController tags = TextEditingController();

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
                          onPressed: widget.videoFile == null
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
                    // _isUploading // Check the upload flag
                    //     ? const Center(
                    //         child: CircularProgressIndicator(),
                    //       )
                    //     :

                    BlocBuilder<UploadBloc, UploadState>(
                      builder: (context, state) {
                        if (state is UploadLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (state is UploadError) {
                          Fluttertoast.showToast(msg: state.message);
                        }
                        if (state is UploadSuccess) {
                          Fluttertoast.showToast(msg: 'Upload Success');
                        }
                        return Center(
                          child: SizedBox(
                            width: 370,
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white),
                              onPressed: () async {
                                context.read<UploadBloc>().add(
                                      UploadFileEvent(
                                        // UploadFileEntities(
                                        //   fileName: widget.videoFile!,
                                        // ),
                                        widget.videoFile!,
                                        false,
                                        false,
                                      ),
                                    );
                                _thumbnailFile != null
                                    ? context
                                        .read<UploadBloc>()
                                        .add(UploadFileEvent(
                                          // UploadFileEntities(
                                          //   fileName:
                                          //       File(_thumbnailFile!.path),
                                          // ),
                                          File(_thumbnailFile!.path),
                                          true,
                                          false,
                                        ))
                                    : context
                                        .read<UploadBloc>()
                                        .add(UploadFileEvent(
                                          // UploadFileEntities(
                                          //     fileName:
                                          //         File(widget.thumbnailPath!)),
                                          File(widget.thumbnailPath!),
                                          true,
                                          false,
                                        ));
                                context
                                    .read<UploadBloc>()
                                    .add(UploadDataEvent(UploadDataEntities(
                                      title: title.text.trim(),
                                      artistName: [artistName.text],
                                      date: DateTime.now(),
                                      tags: tags.text
                                          .split(',')
                                          .map((item) => item.trim())
                                          .toList(),
                                      dislike: 0,
                                      like: 0,
                                      duration: widget.videoDuration,
                                      link: widget.videoFile!.path
                                          .split('/')
                                          .last
                                          .trim(),
                                      thumbnail: _thumbnailFile != null
                                          ? _thumbnailFile!.path.split('/').last
                                          : widget.thumbnailPath!
                                              .split('/')
                                              .last,
                                      trans: false,
                                    )));
                                Navigator.pop(context);
                                // // log(tags.text.split(",").toList().toString());
                                // // log(_thumbnailFile!.path);
                                // setState(() {
                                //   _isUploading = true;
                                // });
                                // //**************** Vidoe Upload ***************** */
                                // if (widget.videoFile != null) {
                                //   await uploadVideo(widget.videoFile!);
                                // } else {
                                //   // Handle case when no file is selected
                                //   ScaffoldMessenger.of(context).showSnackBar(
                                //     const SnackBar(
                                //       content:
                                //           Text('Please select a video first.'),
                                //     ),
                                //   );
                                // }
                                // //*********************************************** */

                                // // log(DateFormat('dd/mm/yyyy')
                                // //     .format(DateTime.now())
                                // //     .toString());

                                // // log(_videoFile!.path.split('/').last.trim());
                                // // log(title.text);
                                // // log([artistName.text].toString());
                                // // log(tags.text);
                                // // log(_thumbnailPath!.split('/').last);
                                // _thumbnailFile != null
                                //     ? await uploadImage(
                                //         File(_thumbnailFile!.path),
                                //         'thumbnail',
                                //       )
                                //     : await uploadImage(
                                //         File(widget.thumbnailPath!),
                                //         'thumbnail',
                                //       );
                                // addNewVideo(
                                //   videoTitle: title.text.trim(),
                                //   artistName: [artistName.text],
                                //   date: DateFormat('dd/MM/yyyy HH:mm')
                                //       .format(DateTime.now())
                                //       .toString(),
                                //   tags: tags.text
                                //       .split(',')
                                //       .map((item) => item.trim())
                                //       .toList(),
                                //   vidoName: widget.videoFile!.path
                                //       .split('/')
                                //       .last
                                //       .trim(),
                                // );
                                // setState(() {
                                //   _isUploading = false;
                                // });
                                // // ignore: use_build_context_synchronously
                                // Navigator.pop(context);
                                // // ignore: use_build_context_synchronously
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   const SnackBar(
                                //     content: Text(
                                //         'Uploading complete please refresh'),
                                //   ),
                                // );
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
                        );
                      },
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
