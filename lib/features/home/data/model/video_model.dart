import '../../domain/entities/video_entity.dart';

class VideoModel extends VideoEntity {
  const VideoModel({
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

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      title: json['title'] as String?,
      link: json['videoLink'] as String?,
      thumbnail: json['videoThumbnail'] as String?,
      like: json['videoLike'] as int?,
      dislike: json['videoDislike'] as int?,
      artistName: (json['artistName'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      date: json['date'] as DateTime?,
      duration: json['duration'] as String?,
      trans: json['trans'] as bool?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'link': link,
      'thumbnail': thumbnail,
      'like': like,
      'dislike': dislike,
      'artistName': artistName,
      'date': date,
      'duration': duration,
      'trans': trans,
      'tags': tags,
    };
  }
}
