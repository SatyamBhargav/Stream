// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/widgets.dart';


class VidoePickerEntity {
  File? videoFile;
  Image? thumbnail;
  String? thumbnailPath;
  String? videoDuration;
  VidoePickerEntity({
    this.videoFile,
    this.thumbnail,
    this.thumbnailPath,
    this.videoDuration,
  });
}
