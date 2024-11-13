// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';

import 'package:videostream/myvideolist.dart';
import 'package:videostream/star.dart';
import 'package:videostream/upload.dart';
import 'package:videostream/videoscreen.dart';

void main() {
  // FlutterError.onError = (FlutterErrorDetails details) {
  //   FlutterError.dumpErrorToConsole(details);
  //   runApp(ErrorWidgetClass(details));
  // };
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
      home: AnimatedSplashScreen(
        splash: 'assets/splashscreen.png',
        centered: true,
        splashIconSize: 250,
        nextScreen: const Scaffold(
          body: MyVideoList(),
        ),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.white,
      ),

      // home: const MyVideoList(),
      // home: const Star(),
      // home: Videoscreen(),
      // home: const Upload(),
    );
  }
}

// import 'package:flutter/material.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: AutoHideAppBarScreen(),
//     );
//   }
// }

// class AutoHideAppBarScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 200.0,
//             floating: false,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               title: Text('Auto Hide App Bar'),
//               background: Image.network(
//                 'https://via.placeholder.com/400',
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           SliverList(
//             delegate: SliverChildBuilderDelegate(
//               (context, index) => ListTile(
//                 title: Text('Item #$index'),
//               ),
//               childCount: 50,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text("YouTube-like App Bar"),
            floating: true,
            snap: true,
            backgroundColor: Colors.red,
            // expandedHeight: 200,
            // flexibleSpace: FlexibleSpaceBar(
            //   background: Container(
            //     color: Colors.redAccent,
            //     child: Center(
            //       child: Text(
            //         'App Bar Background',
            //         style: TextStyle(color: Colors.white, fontSize: 24),
            //       ),
            //     ),
            //   ),
            // ),
          ),
          // SliverList(
          //   delegate: SliverChildBuilderDelegate(
          //     (context, index) => ListTile(
          //       title: Text('Item #$index'),
          //     ),
          //     childCount: 50, // Set the number of list items
          //   ),
          // ),
        ],
      ),
    );
  }
}
