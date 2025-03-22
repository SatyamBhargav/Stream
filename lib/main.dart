import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:videostream/features/category/presentation/bloc/category_bloc.dart';
import 'package:videostream/features/category/presentation/bloc/category_event.dart';

import 'package:videostream/features/category/presentation/cubit/upload_category_data_cubit.dart';

import 'package:videostream/features/ground_zero/presentation/bloc/ground_zero_bloc.dart';
import 'package:videostream/features/ground_zero/presentation/cubit/download_update_cubit.dart';
import 'package:videostream/features/ground_zero/presentation/cubit/update_app_cubit.dart';
import 'package:videostream/features/home/presentation/bloc/video_event.dart';
import 'package:videostream/features/ground_zero/presentation/pages/ground_zero.dart';
import 'package:videostream/features/home/presentation/cubit/random5_cubit.dart';
import 'package:videostream/features/upload/presentation/bloc/upload_bloc.dart';
import 'package:videostream/features/videoplayer/presentation/bloc/subtitle_bloc.dart';
import 'package:videostream/service_locator/injection_container.dart';

import 'features/home/presentation/bloc/video_bloc.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VideoBloc>(
          create: (context) =>
              getIt<VideoBloc>()..add(FetchVideosEvent(page: 0)),
        ),
        BlocProvider<SubtitleBloc>(create: (context) => getIt<SubtitleBloc>()),
        BlocProvider<GroundZeroBloc>(
            create: (context) => getIt<GroundZeroBloc>()),
        BlocProvider<UploadBloc>(create: (context) => getIt<UploadBloc>()),
        BlocProvider<CategoryBloc>(
            create: (context) =>
                getIt<CategoryBloc>()..add(FetchCategoryData())),
        // BlocProvider<UploadStatusCubit>(create: (context) => getIt<UploadStatusCubit>()),
        BlocProvider<UploadCategoryDataCubit>(
            create: (context) => getIt<UploadCategoryDataCubit>()),
        BlocProvider<UpdateAppCubit>(
            create: (context) => getIt<UpdateAppCubit>()),
        BlocProvider<DownloadUpdateCubit>(
            create: (context) => getIt<DownloadUpdateCubit>()),

        BlocProvider<Random5Cubit>(create: (context) => getIt<Random5Cubit>()..onFetchRandomVideo()),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const GroundZero(),
      ),
    );
  }
}
