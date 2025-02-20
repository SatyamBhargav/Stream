import 'package:get_it/get_it.dart';
import 'package:videostream/core/datasource/uploadfile_service.dart';
import 'package:videostream/core/repo/uploadfile_repo.dart';
import 'package:videostream/core/repo/uploadfile_repo_impl.dart';
import 'package:videostream/features/category/data/data_source/category_service.dart';
import 'package:videostream/features/category/data/repo/category_repo_impl.dart';
import 'package:videostream/features/category/domain/repo/category_repo.dart';
import 'package:videostream/features/category/domain/usecases/caegory_load_usecase.dart';
import 'package:videostream/features/category/domain/usecases/category_upload_usecase.dart';
import 'package:videostream/features/category/domain/usecases/select_category_image_usecase.dart';
import 'package:videostream/features/category/domain/usecases/video_load_usecase.dart';
import 'package:videostream/features/category/presentation/bloc/category_bloc.dart';
import 'package:videostream/features/category/presentation/cubit/category_video_cubit.dart';
import 'package:videostream/features/category/presentation/cubit/upload_category_data_cubit.dart';
import 'package:videostream/features/ground_zero/data/data_source/zero_service.dart';
import 'package:videostream/features/ground_zero/data/repo/zero_repo_impl.dart';
import 'package:videostream/features/ground_zero/domain/repo/zero_repo.dart';
import 'package:videostream/features/ground_zero/domain/usecase/cheupdate_usecase.dart';
import 'package:videostream/features/ground_zero/domain/usecase/download_update_usecase.dart';
import 'package:videostream/features/ground_zero/domain/usecase/zero_usecase.dart';
import 'package:videostream/features/ground_zero/presentation/bloc/ground_zero_bloc.dart';
import 'package:videostream/features/ground_zero/presentation/cubit/download_update_cubit.dart';
import 'package:videostream/features/ground_zero/presentation/cubit/update_app_cubit.dart';
import 'package:videostream/features/home/data/data_source/streamhome_api_service.dart';
import 'package:videostream/features/home/data/repo/video_repo_impl.dart';
import 'package:videostream/features/home/domain/repos/video_repository.dart';
import 'package:videostream/features/home/domain/usecase/get_videos_usecase.dart';
import 'package:videostream/features/home/domain/usecase/upload_status_usecase.dart';
import 'package:videostream/features/home/presentation/bloc/video_bloc.dart';
import 'package:videostream/features/home/presentation/cubit/upload_status_cubit.dart';
import 'package:videostream/features/upload/data/data_source/upload_service.dart';
import 'package:videostream/features/upload/data/repo/upload_video_repo.dart';
import 'package:videostream/features/upload/domain/repos/video_repo.dart';
import 'package:videostream/features/upload/domain/usecases/upload_data.dart';
import 'package:videostream/core/usecases/upload_file_usecase.dart';
import 'package:videostream/features/upload/presentation/bloc/upload_bloc.dart';
import 'package:videostream/features/videoplayer/data/data_source/subtitle_service.dart';
import 'package:videostream/features/videoplayer/data/repo/video_player_repo_impl.dart';
import 'package:videostream/features/videoplayer/domain/repos/video_player_repo.dart';
import 'package:videostream/features/videoplayer/domain/usecases/get_subtitle_usecase.dart';
import 'package:videostream/features/videoplayer/presentation/bloc/subtitle_bloc.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<UploadFileServiceSource>(
      () => UploadFileServiceSourceImpl());
  getIt.registerLazySingleton<UploadFileRepository>(
      () => UploadFileRepositoryImpl(getIt<UploadFileServiceSource>()));

  getIt.registerLazySingleton<VideoRemoteDataSource>(
      () => VideoRemoteDataSourceImpl());
  getIt.registerLazySingleton<VideoRepository>(
      () => VideoRepositoryImpl(getIt<VideoRemoteDataSource>()));
  getIt.registerLazySingleton<GetVideosHomeUseCase>(
      () => GetVideosHomeUseCase(getIt<VideoRepository>()));
  // getIt.registerLazySingleton<FilterVideosUseCase>(() => FilterVideosUseCase());

  getIt.registerFactory<VideoBloc>(
      () => VideoBloc(getIt<GetVideosHomeUseCase>()));

  getIt.registerLazySingleton<SubtitleDataSource>(
      () => SubtitleDataSourceImpl());
  getIt.registerLazySingleton<SubtitleRepository>(
      () => SubtitleRepoImpl(getIt<SubtitleDataSource>()));
  getIt.registerLazySingleton<GetSubtitleUseCase>(
      () => GetSubtitleUseCase(getIt<SubtitleRepository>()));
  getIt.registerFactory<SubtitleBloc>(
      () => SubtitleBloc(getIt<GetSubtitleUseCase>()));

  getIt.registerLazySingleton<VideoPickerDataSource>(
      () => VideoPickerDataSourceImpl());
  getIt.registerLazySingleton<VidoePickerRepo>(
      () => VidoePickerRepoImpl(getIt<VideoPickerDataSource>()));
  getIt.registerLazySingleton<GetZeroUsecase>(
      () => GetZeroUsecase(getIt<VidoePickerRepo>()));
  getIt.registerFactory<GroundZeroBloc>(
      () => GroundZeroBloc(getIt<GetZeroUsecase>()));

  getIt.registerLazySingleton<UploadServiceSource>(
      () => UploadServiceSourceImpl());
  getIt.registerLazySingleton<UploadRepository>(
      () => UploadRepositoryImpl(getIt<UploadServiceSource>()));
  getIt.registerLazySingleton<UploadVideoUseCase>(
      () => UploadVideoUseCase(getIt<UploadRepository>()));
  getIt.registerLazySingleton<UploadFileUseCase>(
      () => UploadFileUseCase(getIt<UploadFileRepository>()));
  getIt.registerFactory<UploadBloc>(() =>
      UploadBloc(getIt<UploadFileUseCase>(), getIt<UploadVideoUseCase>()));

  getIt.registerLazySingleton<CategoryDataSource>(
      () => CategoryDataSourceImpl());
  getIt.registerLazySingleton<CategoryRepo>(
      () => CategoryRepoImpl(getIt<CategoryDataSource>()));
  getIt.registerLazySingleton<CaegoryLoadDataUsecase>(
      () => CaegoryLoadDataUsecase(getIt<CategoryRepo>()));
  getIt.registerLazySingleton<CategoryUploadUsecase>(
      () => CategoryUploadUsecase(getIt<CategoryRepo>()));
  getIt.registerFactory<CategoryBloc>(() => CategoryBloc(
        getIt<CategoryUploadUsecase>(),
        getIt<CaegoryLoadDataUsecase>(),
      ));

  getIt.registerLazySingleton<GetCategoryVideoUseCase>(
      () => GetCategoryVideoUseCase(getIt<CategoryRepo>()));
  getIt.registerFactory<CategoryVideoCubit>(() => CategoryVideoCubit(
        getIt<GetCategoryVideoUseCase>(),
      ));

  getIt.registerLazySingleton<UploadStatusUsecase>(
      () => UploadStatusUsecase(getIt<VideoRepository>()));
  getIt.registerFactory<UploadStatusCubit>(() => UploadStatusCubit(
        getIt<UploadStatusUsecase>(),
      ));

  getIt.registerLazySingleton<UpdateCategoryImageUseCase>(
      () => UpdateCategoryImageUseCase(getIt<CategoryRepo>()));
  getIt.registerFactory<UploadCategoryDataCubit>(() => UploadCategoryDataCubit(
        getIt<CategoryUploadUsecase>(),
        getIt<UpdateCategoryImageUseCase>(),
        getIt<UploadFileUseCase>(),
      ));

  getIt.registerLazySingleton<CheupdateUsecase>(
      () => CheupdateUsecase(getIt<VidoePickerRepo>()));
  getIt.registerFactory<UpdateAppCubit>(
      () => UpdateAppCubit(getIt<CheupdateUsecase>()));

  getIt.registerLazySingleton<DownloadUpdateUsecase>(
      () => DownloadUpdateUsecase(getIt<VidoePickerRepo>()));
  getIt.registerLazySingleton<VidoePickerRepoImpl>(
      () => VidoePickerRepoImpl(getIt<VideoPickerDataSource>()));
  getIt.registerFactory<DownloadUpdateCubit>(
      () => DownloadUpdateCubit(getIt<DownloadUpdateUsecase>()));
}
