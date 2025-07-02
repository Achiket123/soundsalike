import 'package:dartz/dartz.dart';
import 'package:record/record.dart';
import 'package:soundsalike/features/recording/domain/entities/fingerprints_entity.dart';

abstract class RecordingRepo {
  Future<Either<Exception, void>> startRecording(AudioRecorder recorder);
  Future<Either<Exception, List<FingerprintsEntity>>> stopRecording(
    AudioRecorder recorder,
  );
}
