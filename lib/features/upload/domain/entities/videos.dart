class UploadDataEntities {
  final String? title;
  final String? link;
  final String? thumbnail;
  final int? like;
  final int? dislike;
  final List? artistName;
  final DateTime? date;
  final String? duration;
  final bool? trans;
  final List? tags;

  const UploadDataEntities({
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

  bool get isValidVideoLink {
    return link!.startsWith('http://') && link!.endsWith('.mp4');
  }
}

// class UploadFileEntities {
//   final File? fileName;
//   const UploadFileEntities({
//     this.fileName,
//   });
// }
