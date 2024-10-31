import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

Widget formatedText({
  required String text,
  required String fontFamily,
  double? size = 17,
  FontWeight? fontweight = FontWeight.w400,
  Color? color,
  TextDecoration? decoration,
}) {
  return Text(
    text,
    // overflow: TextOverflow.ellipsis,
    // maxLines: 1,
    style: GoogleFonts.getFont(
      fontFamily,
      color: color,
      fontSize: size,
      fontWeight: fontweight,
      decoration: decoration,
    ),
  );
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}

String timeAgo(String dateString) {
  DateFormat format = DateFormat('dd/MM/yyyy');
  DateTime inputDate = format.parse(dateString);
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
