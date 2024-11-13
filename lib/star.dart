import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:videostream/multi_use_widget.dart';

class Star extends StatelessWidget {
  const Star({super.key});

  void numberOfVide(String artistName) {
    final jsonValue = checkvalue();
    log(jsonValue.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Star'),
          centerTitle: true,
          actions: [
            ElevatedButton(
                onPressed: () {
                  numberOfVide('indian');
                },
                child: Text('data'))
          ],
        ),
        body: GridView(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 9 / 16,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.amber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Padding(
                    padding: EdgeInsets.only(left: 3),
                    child: Text(
                      'Star name',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 3),
                    child: Text('123 Videos'),
                  )
                ],
              ),
            ),
          ],
        )

        // GridView.builder(
        //   gridDelegate:
        //       const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        //   itemBuilder: (context, index) {
        //     return SizedBox(
        //       height: 1,
        //       child: Column(
        //         children: [
        //           AspectRatio(
        //             aspectRatio: 9 / 16,
        //             child: Container(
        //               color: Colors.amber,
        //             ),
        //           ),
        //           Text('data')
        //         ],
        //       ),
        //     );
        //   },
        // ),
        );
  }
}
