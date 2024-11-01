import 'package:flutter/material.dart';
import 'package:videostream/myvideolist.dart';
import 'package:videostream/upload.dart';
import 'package:videostream/videoscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: const MyVideoList(),
      // home: Videoscreen(),
      // home: const Upload(),
    );
  }
}
