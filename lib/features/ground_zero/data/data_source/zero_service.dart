import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:videostream/core/utility/time_manupulator.dart';
import 'package:videostream/features/ground_zero/data/model/zero_model.dart';

abstract class VideoPickerDataSource {
  Future<VideoPickerModle> getVideo();
  Future<List> getLatestAppVersion();
  Future<void> downloadLatestUpdate(Function(int) onProgress);
}

class VideoPickerDataSourceImpl implements VideoPickerDataSource {
  final dio = Dio();
  final ValueNotifier<String> downloadUrl = ValueNotifier<String>('');
  @override
  Future<VideoPickerModle> getVideo() async {
    File? videoFile;

    // Open the file picker to select a video file
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      // Get the path of the selected video file
      String? filePath = result.files.single.path;

      if (filePath != null) {
        videoFile = File(filePath);
        final finalData = await _generateThumbnail(videoFile);
        // Generate a thumbnail from the selected video
        // await Future.delayed(const Duration(seconds: 5));

        return finalData;
      } else {
        throw Exception('No valid file path found.');
      }
    } else {
      // Handle the case where no file was selected

      throw Exception('No file selected.');
    }
  }

  Future<VideoPickerModle> _generateThumbnail(File? videoFile) async {
    String? videoDuration;

    // Create a VideoPlayerController to get the video's dimensions
    final controller = VideoPlayerController.file(videoFile!);
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
      video: videoFile.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: maxWidth,
      maxHeight: maxHeight, // Use the calculated max height
      quality: 75,
    );

    controller.dispose();
    return VideoPickerModle(
      videoFile: videoFile,
      thumbnail: Image.file(
        File(thumbnailPath.path),
      ),
      thumbnailPath: thumbnailPath.path,
      videoDuration: videoDuration,
    );
  }

  @override
  Future<List> getLatestAppVersion() async {
    final response = await dio.get(
        'https://api.github.com/repos/SatyamBhargav/Stream/releases/latest');
    if (response.statusCode == 200) {
      downloadUrl.value = response.data['assets'][0]['browser_download_url'];
      final latestAppVersion = response.data['tag_name'];
      final currentAppVersion = await getAppVersion();
      if (latestAppVersion != currentAppVersion) {
        return [true, latestAppVersion, currentAppVersion];
      }
      return [false];
    } else {
      throw Exception("Failed to fetch latest release.");
    }
  }

  Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Future<void> downloadLatestUpdate(Function(int) onProgress) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/app-update.apk';
      if (kDebugMode) {
        log('Downloading APK to: $filePath');
      }

      Dio dio = Dio();
      // await dio.download(downloadUrl.value, filePath,
      //     onReceiveProgress: (actualBytes, int totalBytes) {
      //   int progress = (actualBytes / totalBytes * 100).floor();
      // });

      await dio.download(downloadUrl.value, filePath,
          onReceiveProgress: (actualBytes, int totalBytes) {
        onProgress((actualBytes / totalBytes * 100).floor());
      });

      if (kDebugMode) {
        log('APK downloaded successfully.');
      }
      // Step 3: Prompt the user to install the APK
      await OpenFilex.open(filePath);
      // log('OpenFile result: $result');
    } catch (e) {
      log('Error during app update: $e');
    }
  }
}
