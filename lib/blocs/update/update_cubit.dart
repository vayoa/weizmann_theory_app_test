import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:weizmann_theory_app_test/blocs/update/version.dart';

part 'update_state.dart';

class UpdateCubit extends Cubit<UpdateState> {
  UpdateCubit() : super(UpdateInitial(currentVersion));

  static final Version currentVersion = Version("0.8.0.7", true);

  static final String appPath = Directory.current.path;

  final Uri githubVersionUri = Uri.parse(
      "https://api.github.com/repos/vayoa/weizmann_theory_app_test/releases");

  CancelToken? downloadCancel;
  Version? newestVersion;

  Future<Version> _loadLatestGithubVersion() async =>
      Version.fromJson(jsonDecode(await http.read(githubVersionUri))[0]);

  Future checkForUpdates() async {
    emit(UpdateLoading(currentVersion));
    newestVersion = await _loadLatestGithubVersion();
    if (newestVersion! > currentVersion) {
      return emit(
          UpdateAvailable(version: currentVersion, update: newestVersion!));
    } else {
      return emit(FullyUpdated(currentVersion));
    }
  }

  Future downloadNewVersion(Version update) async {
    final dio = Dio();
    final temp = (await getApplicationSupportDirectory()).path;
    final documents = (await getApplicationDocumentsDirectory()).path;
    final name = '\\WeizmannTheoryApp $update';
    final directory = '$temp$name.zip';
    emit(DownloadingUpdate(version: currentVersion, update: update));
    downloadCancel = CancelToken();
    await dio.download(
      update.downloadUrl!,
      directory,
      cancelToken: downloadCancel,
      deleteOnError: true,
      onReceiveProgress: (count, total) => emit(
        DownloadingUpdate(
          version: currentVersion,
          update: update,
          progress: count / total,
        ),
      ),
    );
    dio.close();
    emit(UpdateDownloaded(version: currentVersion, update: update));
    // TODO: Change the location of the download to program files...
    emit(ExtractingUpdate(version: currentVersion, update: update));
    final archive = ZipDecoder().decodeBuffer(InputFileStream(directory));
    final outputPath = '$documents\\WeizmannTheoryApp$name';
    extractArchiveToDisk(archive, outputPath);
    return emit(UpdateExtracted(
      location: outputPath,
      version: currentVersion,
      update: update,
    ));
  }

  cancelDownload() async {
    if (state is DownloadingUpdate && newestVersion != null) {
      downloadCancel?.cancel();
      return emit(
          UpdateAvailable(version: currentVersion, update: newestVersion!));
    }
  }
}
