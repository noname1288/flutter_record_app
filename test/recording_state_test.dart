import 'package:flutter_test/flutter_test.dart';
import 'package:record_app/features/recording/domain/entities/recording_phase.dart';
import 'package:record_app/features/recording/presentation/state/recording_state.dart';

void main() {
  test('recording state exposes correct actions per phase', () {
    const idle = RecordingState();
    expect(idle.canStart, isTrue);
    expect(idle.canPause, isFalse);
    expect(idle.canResume, isFalse);
    expect(idle.canStop, isFalse);

    const recording = RecordingState(phase: RecordingPhase.recording);
    expect(recording.canStart, isFalse);
    expect(recording.canPause, isTrue);
    expect(recording.canResume, isFalse);
    expect(recording.canStop, isTrue);

    const paused = RecordingState(phase: RecordingPhase.paused);
    expect(paused.canResume, isTrue);
    expect(paused.canStop, isTrue);

    const stopped = RecordingState(phase: RecordingPhase.stopped);
    expect(stopped.canStart, isTrue);
  });
}
