part of 'record_bloc.dart';

sealed class RecordEvent extends Equatable {
  const RecordEvent();

  @override
  List<Object> get props => [];
}

class StartRecordingEvent extends RecordEvent {
  const StartRecordingEvent();

  @override
  List<Object> get props => [];
}

class StopRecordingEvent extends RecordEvent {
  const StopRecordingEvent();

  @override
  List<Object> get props => [];
}
