import 'package:flutter/widgets.dart';
import 'package:videostream/features/ground_zero/data/data_source/zero_service.dart';
import 'package:videostream/features/ground_zero/data/model/zero_model.dart';
import 'package:videostream/features/ground_zero/domain/entities/zero_entity.dart';
import 'package:videostream/features/ground_zero/domain/repo/zero_repo.dart';

class VidoePickerRepoImpl implements VidoePickerRepo {
  final VideoPickerDataSource remoteDataSource;

  VidoePickerRepoImpl(this.remoteDataSource);
  final ValueNotifier<int> downloadProgressNotifier = ValueNotifier<int>(0);

  @override
  Future<VidoePickerEntity> fetchVidoeFile() async {
    try {
      VideoPickerModle data = await remoteDataSource.getVideo();
      return data;
    } catch (e) {
      throw Exception("Failed to fetch videos");
    }
  }

  @override
  Future<void> downloadUpdate(Function(int) onProgress) async {
    try {
      await remoteDataSource.downloadLatestUpdate(onProgress);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List> getLatestVersion() async {
    try {
      final newUpdateAvailable = await remoteDataSource.getLatestAppVersion();
      return newUpdateAvailable;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
