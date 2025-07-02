import 'package:dartz/dartz.dart';
import 'package:record/record.dart';
import 'package:soundsalike/features/recording/data/datasources/recording_data_source.dart';
import 'package:soundsalike/features/recording/data/models/fingerprints_model.dart';
import 'package:soundsalike/features/recording/domain/repo/recording_repo.dart';

class RecordingRepoImpl implements RecordingRepo {
  const RecordingRepoImpl({required RecordingDataSource recordingDataSource})
    : _recordingDataSource = recordingDataSource;

  final RecordingDataSource _recordingDataSource;

  @override
  Future<Either<Exception, void>> startRecording(AudioRecorder recorder) {
    return _recordingDataSource.startRecording(recorder);
  }

  @override
   Future<Either<Exception, List<FingerprintModel>>> stopRecording(AudioRecorder recorder) {
    return _recordingDataSource.stopRecording(recorder);
  }
}
