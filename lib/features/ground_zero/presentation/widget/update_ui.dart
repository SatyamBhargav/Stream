import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:videostream/features/ground_zero/presentation/cubit/download_update_cubit.dart';
import 'package:videostream/features/ground_zero/presentation/cubit/update_app_cubit.dart';

// ignore: non_constant_identifier_names
void UpdateUi(BuildContext context, UpdateAppState state) async {
  // final repository = RepositoryProvider.of<VidoePickerRepoImpl>(context);

  if (state is UpdateAppLoded) {
    // log(' version ${state.appStatus}');
    if (state.appStatus == true) {
      await Future.delayed(const Duration(seconds: 2));

      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: Colors.transparent,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                width: 300,
                decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(30)),
                child: Column(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.info(),
                      size: 35,
                    ),
                    const SizedBox(height: 10),
                    Text('v${state.latestVersion}',
                        style: const TextStyle(
                          fontSize: 30,
                        )),
                    const SizedBox(height: 10),
                    Text(
                      'New app version available\ncurrent v${state.currentVersion}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            if (kDebugMode) {
                              log('update button working');
                            }
                            context.read<DownloadUpdateCubit>().updateApp();
                          },
                          child: Container(
                            height: 49,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              border: Border.all(color: Colors.grey[900]!),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: BlocBuilder<DownloadUpdateCubit,
                                DownloadUpdateState>(
                              builder: (context, state) {
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  transitionBuilder: (child, animation) =>
                                      FadeTransition(
                                          opacity: animation, child: child),
                                  child: state is AppUpdateInProgress
                                      ? Text(
                                          "${state.progress}%",
                                          key: const ValueKey(1),
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white),
                                        )
                                      : const Text(
                                          'Update',
                                          key: ValueKey(2),
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600),
                                        ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          );
        },
      );
    }
  }
}
