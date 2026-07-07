import 'package:equatable/equatable.dart';
import 'package:record_app/features/recording/domain/entities/recording_phase.dart';

class RecordingState extends Equatable {
  const RecordingState({
    this.phase = RecordingPhase.idle,
    this.elapsed = Duration.zero,
    this.filePath,
    this.errorMessage,
    this.isBusy = false,
  });

  final RecordingPhase phase;
  final Duration elapsed;
  final String? filePath;
  final String? errorMessage;
  final bool isBusy;

  bool get canStart =>
      !isBusy && (phase == RecordingPhase.idle || phase == RecordingPhase.stopped);

  bool get isRecording => phase == RecordingPhase.recording;

  bool get isPaused => phase == RecordingPhase.paused;

  bool get canPause => !isBusy && phase == RecordingPhase.recording;

  bool get canResume => !isBusy && phase == RecordingPhase.paused;

  bool get canStop =>
      !isBusy &&
      (phase == RecordingPhase.recording || phase == RecordingPhase.paused);

  RecordingState copyWith({
    RecordingPhase? phase,
    Duration? elapsed,
    String? filePath,
    String? errorMessage,
    bool? isBusy,
    bool clearError = false,
    bool clearFilePath = false,
  }) {
    return RecordingState(
      phase: phase ?? this.phase,
      elapsed: elapsed ?? this.elapsed,
      filePath: clearFilePath ? null : (filePath ?? this.filePath),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isBusy: isBusy ?? this.isBusy,
    );
  }

  @override
  List<Object?> get props => [phase, elapsed, filePath, errorMessage, isBusy];
}
