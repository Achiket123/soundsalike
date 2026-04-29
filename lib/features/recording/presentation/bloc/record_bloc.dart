import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';
import 'package:soundsalike/features/recording/domain/entities/fingerprints_entity.dart';
import 'package:soundsalike/features/recording/domain/repo/recording_repo.dart';

part 'record_event.dart';
part 'record_state.dart';

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final AudioRecorder _audioRecorder;
  final RecordingRepo _recordingRepo;

  RecordBloc({
    required AudioRecorder audioRecorder,
    required RecordingRepo recordingRepo,
  })  : _audioRecorder = audioRecorder,
        _recordingRepo = recordingRepo,
        super( RecordInitial()) {
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingEvent>(_onStopRecording);
  }

  Future<void> _onStartRecording(
    StartRecordingEvent event,
    Emitter<RecordState> emit,
  ) async {
    emit(const RecordingLoading());
    final result = await _recordingRepo.startRecording(_audioRecorder);
    result.fold(
      (err) => emit(RecordingError(err.toString())),
      (_) => emit(const RecordingInProgress()),
    );
  }

  Future<void> _onStopRecording(
    StopRecordingEvent event,
    Emitter<RecordState> emit,
  ) async {
    emit(const RecordingLoading());
    final result = await _recordingRepo.stopRecording(_audioRecorder);
    result.fold(
      (err) => emit(RecordingError(err.toString())),
      (data) => emit(RecordingStopped(data)),
    );
  }
}