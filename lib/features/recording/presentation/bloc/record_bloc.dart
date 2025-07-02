import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:record/record.dart';
import 'package:soundsalike/features/recording/domain/entities/fingerprints_entity.dart';
import 'package:soundsalike/features/recording/domain/repo/recording_repo.dart';
import 'package:soundsalike/widgets/mic_widget.dart';

part 'record_event.dart';
part 'record_state.dart';

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final AudioRecorder _audioRecorder;

  final RecordingRepo _recordingRepo;
  RecordBloc({
    required AudioRecorder audioRecorder,
    required RecordingRepo recordingRepo,
  }) : _audioRecorder = audioRecorder,
       _recordingRepo = recordingRepo,
       super(RecordInitial()) {
    on<RecordEvent>((event, emit) {});
    on<StartRecordingEvent>(_handleStartRecordingEvent);
    on<StopRecordingEvent>(_handleStopRecordingEvent);
  }

  _handleStartRecordingEvent(
    StartRecordingEvent event,
    Emitter<RecordState> emit,
  ) async {
    try {
      emit(RecordingLoading());
      final result = await _recordingRepo.startRecording(_audioRecorder);
      result.fold(
        (ifLeft) => emit(RecordingError(ifLeft.toString())),
        (ifRight) => emit(RecordingInProgress()),
      );
    } catch (e) {
      emit(RecordingError(e.toString()));
    }
  }

  _handleStopRecordingEvent(event, emit) async {
    try {
      emit(RecordingLoading());
      final result = await _recordingRepo.stopRecording(_audioRecorder);
      result.fold(
        (ifLeft) => emit(RecordingError(ifLeft.toString())),
        (ifRight) => emit(RecordingStopped(ifRight)),
      );
    } catch (e) {
      emit(RecordingError(e.toString()));
    }
  }
}
