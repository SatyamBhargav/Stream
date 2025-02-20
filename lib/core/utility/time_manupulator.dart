// import 'package:intl/intl.dart';

String timeAgo(DateTime inputDate) {
  DateTime currentDate = DateTime.now();
  Duration difference = currentDate.difference(inputDate);

  if (difference.inDays >= 30) {
    int months = (difference.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  } else if (difference.inDays >= 1) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inHours >= 1) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inMinutes >= 1) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return 'just now';
  }
}


String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}

int timeToMilliseconds(String time) {
  List<String> parts = time.split(':');
  List<String> secondsAndMilliseconds = parts[2].split(',');
  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1]);
  int seconds = int.parse(secondsAndMilliseconds[0]);
  int milliseconds = int.parse(secondsAndMilliseconds[1]);

  return (((hours * 60 + minutes) * 60 + seconds) * 1000 + milliseconds);
}
