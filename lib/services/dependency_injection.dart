import 'package:get_it/get_it.dart';
import 'package:record/record.dart';
import 'package:soundsalike/features/recording/data/datasources/recording_data_source.dart';
import 'package:soundsalike/features/recording/data/repo/recording_repo_impl.dart';
import 'package:soundsalike/features/recording/domain/repo/recording_repo.dart';
import 'package:soundsalike/features/recording/presentation/bloc/record_bloc.dart';

final getIt = GetIt.instance;

void dependencyInjection() {
  getIt.registerLazySingleton<RecordingDataSource>(
    () => RecordingDataSourceImpl(),
  );

  getIt.registerLazySingleton<RecordingRepo>(
    () => RecordingRepoImpl(recordingDataSource: getIt<RecordingDataSource>()),
  );

  // AudioRecorder must be a singleton — creating multiple instances can
  // cause platform channel conflicts on Android/iOS.
  getIt.registerLazySingleton<AudioRecorder>(() => AudioRecorder());

  getIt.registerFactory<RecordBloc>(
    () => RecordBloc(
      recordingRepo: getIt<RecordingRepo>(),
      audioRecorder: getIt<AudioRecorder>(),
    ),
  );
}