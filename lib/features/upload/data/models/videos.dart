import 'package:videostream/features/upload/domain/entities/videos.dart';

class UploadDataModel extends UploadDataEntities {
  const UploadDataModel({
    super.title,
    super.link,
    super.thumbnail,
    super.like,
    super.dislike,
    super.artistName,
    super.date,
    super.duration,
    super.trans,
    super.tags,
  });

  //? convert post -> json
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "videoLink": "http://192.168.1.114/videos/$link",
      "videoThumbnail": "http://192.168.1.114/videos/thumbnail/$thumbnail",
      "videoLike": like,
      "videoDislike": dislike,
      "artistName": artistName,
      "date": date,
      "duration": duration,
      "trans": trans,
      "tags": tags
    };
  }

  // //? convert json -> post
  // factory UploadDataModel.fromJson(Map<String, dynamic> json) {
  //   return UploadDataModel(
  //     title: json['title'],
  //     link: json['videoLink'],
  //     thumbnail: json['videoThumbnail'],
  //     like: json['like'],
  //     dislike: json['dislike'],
  //     artistName: json['artistName'],
  //     date: json['uploadDate'],
  //     duration: json['videoDuration'],
  //     trans: json['trans'],
  //     tags: json['videoTags'],
  //   );
  // }
}

// class UploadFileModel extends UploadFileEntities {
//   const UploadFileModel({
//     super.fileName,
//   });
// }
