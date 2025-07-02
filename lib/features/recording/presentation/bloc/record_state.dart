part of 'record_bloc.dart';

sealed class RecordState extends Equatable {
  const RecordState();

  @override
  List<Object> get props => [];
}

final class RecordInitial extends RecordState {}

final class RecordingInProgress extends RecordState {
  const RecordingInProgress();

  @override
  List<Object> get props => [];
}

final class RecordingLoading extends RecordState {
  const RecordingLoading();
}

final class RecordingStopped extends RecordState {
  List<FingerprintsEntity> data;
  RecordingStopped(this.data);

  @override
  List<Object> get props => [data];
}

final class RecordingError extends RecordState {
  const RecordingError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
