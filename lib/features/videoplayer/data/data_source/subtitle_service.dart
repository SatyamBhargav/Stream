import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:videostream/core/utility/time_manupulator.dart';
import 'package:videostream/features/videoplayer/data/model/video_player_model.dart';

abstract class SubtitleDataSource {
  Future<SubtitleModel> getSubtitle();
}

class SubtitleDataSourceImpl implements SubtitleDataSource {
  @override
  Future<SubtitleModel> getSubtitle() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      // log(result.toString());
      if (result != null) {
        try {
          // Read the content of the selected file
          File subtitleFile = File(result.files.single.path!);
          String fileContent = await subtitleFile.readAsString();

          SubtitleModel parsedSubtitles =
              SubtitleModel(subtitles: parseSrtFile(fileContent));

          return parsedSubtitles;
        } catch (e) {
          throw Exception('Failed to parse subtitles : $e');
        }
      } else {
        if (kDebugMode) {
          log('No file selected');
        }
        throw Exception('No file selected');
      }
    } catch (e) {
      throw Exception('Failed to fetch subtitles');
    }
  }
}

List<Map<String, dynamic>> parseSrtFile(String content) {
  List<Map<String, dynamic>> parsedSubtitles = [];
  List<String> lines = content.split('\n');
  int index = 0;

  while (index < lines.length) {
    // Check for a subtitle block
    String line = lines[index].trim();
    if (line.isEmpty) {
      index++;
      continue;
    }

    // Parse the subtitle index
    int subtitleIndex = int.tryParse(line) ?? -1;
    if (subtitleIndex != -1) {
      // Parse the time range
      index++;
      String timeRange = lines[index].trim();
      List<String> times = timeRange.split(' --> ');
      if (times.length == 2) {
        int startTime = timeToMilliseconds(times[0]);
        int endTime = timeToMilliseconds(times[1]);

        // Parse the subtitle text
        index++;
        String subtitleText = '';
        while (index < lines.length && lines[index].trim().isNotEmpty) {
          subtitleText += '${lines[index].trim()}\n';
          index++;
        }

        // Add to parsedSubtitles
        parsedSubtitles.add({
          'start': startTime ~/ 1000, // Convert to seconds
          'end': endTime ~/ 1000, // Convert to seconds
          'text': subtitleText.trim(),
        });
      }
    }
    index++;
  }
  return parsedSubtitles;
}
