import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record_app/core/error/recording_exception.dart';
import 'package:record_app/features/recording/domain/entities/recording_phase.dart';
import 'package:record_app/features/recording/presentation/providers/recording_providers.dart';
import 'package:record_app/features/recording/presentation/state/recording_state.dart';
import 'package:uuid/uuid.dart';

final recordingNotifierProvider =
    NotifierProvider.autoDispose<RecordingNotifier, RecordingState>(
  RecordingNotifier.new,
);

class RecordingNotifier extends Notifier<RecordingState> {
  Timer? _timer;
  DateTime? _segmentStart;
  Duration _accumulated = Duration.zero;

  @override
  RecordingState build() {
    ref.onDispose(_disposeTimer);
    return const RecordingState();
  }

  Future<void> start() async {
    if (!state.canStart) return;

    state = state.copyWith(isBusy: true, clearError: true);

    try {
      final repository = ref.read(recordingRepositoryProvider);
      final granted = await repository.hasPermission();
      if (!granted) {
        throw const RecordingException('Microphone permission denied.');
      }

      final filePath = await _newRecordingPath();
      await repository.start(filePath: filePath);

      _accumulated = Duration.zero;
      _startTimer();

      state = state.copyWith(
        phase: RecordingPhase.recording,
        elapsed: Duration.zero,
        filePath: filePath,
        isBusy: false,
        clearError: true,
      );
    } on RecordingException catch (error) {
      state = state.copyWith(isBusy: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: 'Failed to start recording.',
      );
    }
  }

  Future<void> pause() async {
    if (!state.canPause) return;

    state = state.copyWith(isBusy: true, clearError: true);

    try {
      await ref.read(recordingRepositoryProvider).pause();
      _pauseTimer();

      state = state.copyWith(
        phase: RecordingPhase.paused,
        isBusy: false,
        clearError: true,
      );
    } on RecordingException catch (error) {
      state = state.copyWith(isBusy: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: 'Failed to pause recording.',
      );
    }
  }

  Future<void> resume() async {
    if (!state.canResume) return;

    state = state.copyWith(isBusy: true, clearError: true);

    try {
      await ref.read(recordingRepositoryProvider).resume();
      _startTimer();

      state = state.copyWith(
        phase: RecordingPhase.recording,
        isBusy: false,
        clearError: true,
      );
    } on RecordingException catch (error) {
      state = state.copyWith(isBusy: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: 'Failed to resume recording.',
      );
    }
  }

  Future<void> stop() async {
    if (!state.canStop) return;

    state = state.copyWith(isBusy: true, clearError: true);

    try {
      final filePath = await ref.read(recordingRepositoryProvider).stop();
      _pauseTimer();

      state = state.copyWith(
        phase: RecordingPhase.stopped,
        filePath: filePath,
        isBusy: false,
        clearError: true,
      );
    } on RecordingException catch (error) {
      state = state.copyWith(isBusy: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: 'Failed to stop recording.',
      );
    }
  }

  Future<String> _newRecordingPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${const Uuid().v4()}.m4a';
    return p.join(directory.path, fileName);
  }

  void _startTimer() {
    _segmentStart = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tickElapsed());
    _tickElapsed();
  }

  void _pauseTimer() {
    if (_segmentStart != null) {
      _accumulated += DateTime.now().difference(_segmentStart!);
      _segmentStart = null;
    }
    _timer?.cancel();
    _timer = null;
  }

  void _tickElapsed() {
    if (_segmentStart == null) return;
    final segment = DateTime.now().difference(_segmentStart!);
    state = state.copyWith(elapsed: _accumulated + segment);
  }

  void _disposeTimer() {
    _timer?.cancel();
    _timer = null;
    _segmentStart = null;
    _accumulated = Duration.zero;
  }
}
