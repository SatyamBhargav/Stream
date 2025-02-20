class VideoEntity {
  final String? title;
  final String? link;
  final String? thumbnail;
  final int? like;
  final int? dislike;
  final List<String>? artistName;
  final DateTime? date;
  final String? duration;
  final bool? trans;
  final List<String>? tags;

  const VideoEntity({
    this.title,
    this.link,
    this.thumbnail,
    this.like,
    this.dislike,
    this.artistName,
    this.date,
    this.duration,
    this.trans,
    this.tags,
  });
}
