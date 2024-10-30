import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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