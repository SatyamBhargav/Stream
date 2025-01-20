// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:videostream/screen/home.dart';

import 'package:videostream/screen/myvideolist.dart';
import 'package:videostream/screen/selectserver.dart';
import 'package:videostream/screen/star.dart';
import 'package:videostream/screen/stardetails.dart';
import 'package:videostream/screen/upload.dart';
import 'package:videostream/videoscreen.dart';

void main() async {
  // FlutterError.onError = (FlutterErrorDetails details) {
  //   FlutterError.dumpErrorToConsole(details);
  //   runApp(ErrorWidgetClass(details));
  // };
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await NoScreenshot.instance.screenshotOff();

  runApp(const MyApp());
}

class ErrorWidgetClass extends StatelessWidget {
  final FlutterErrorDetails errorDetails;
  const ErrorWidgetClass(this.errorDetails, {super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Error Widget Example',
      home: CustomErrorWidget(errorMessage: errorDetails.exceptionAsString()),
    );
  }
}

class CustomErrorWidget extends StatelessWidget {
  final String errorMessage;
  const CustomErrorWidget({
    Key? key,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber,
            size: 30,
            color: Colors.red,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Error Occured!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
              child: Text(
            errorMessage,
            style: const TextStyle(fontSize: 13),
          )),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      // home: AnimatedSplashScreen(
      //   splash: 'assets/splashscreen.png',
      //   centered: true,
      //   splashIconSize: 250,
      //   nextScreen: const Scaffold(
      //     body: MyVideoList(),
      //   ),
      //   splashTransition: SplashTransition.fadeTransition,
      //   backgroundColor: Colors.white,
      // ),
      // home: const StarDetail(collectionName: 'jav'),
      home: const HomePage(),
      // home: SelectServer(),
      // home: MyVideoList(password: '',),
      // home: const Star(),
      // home: Videoscreen(),
      // home: const Upload(),
    );
  }
}
