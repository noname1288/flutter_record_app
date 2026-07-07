import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_app/features/recording/domain/entities/recording_phase.dart';
import 'package:record_app/features/recording/presentation/providers/recording_notifier.dart';
import 'package:record_app/features/recording/presentation/state/recording_state.dart';

class ControlsButtonRow extends ConsumerWidget {
  const ControlsButtonRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordingNotifierProvider);
    final notifier = ref.read(recordingNotifierProvider.notifier);

    if (state.canStart) {
      return _buildStartButton(notifier, state);
    }
    if (state.isRecording) {
      return _buildRecordingControls(notifier, state);
    }
    if (state.isPaused) {
      return _buildPausedControls(notifier, state);
    }
    return _buildStartButton(notifier, state);
  }

  Widget _buildStartButton(RecordingNotifier notifier, RecordingState state) {
    return Row(
      children: [
        const Expanded(child: SizedBox.shrink()),
        Expanded(
          child: RecordControlButton(
            icon: Icons.fiber_manual_record,
            label: 'Record',
            enabled: state.canStart,
            onPressed: notifier.start,
          ),
        ),
        const Expanded(child: SizedBox.shrink()),
      ],
    );
  }

  Widget _buildRecordingControls(
    RecordingNotifier notifier,
    RecordingState state,
  ) {
    return Row(
      children: [
        const Expanded(child: SizedBox.shrink()),
        Expanded(
          child: RecordControlButton(
            icon: Icons.pause,
            label: 'Pause',
            enabled: state.canPause,
            onPressed: notifier.pause,
          ),
        ),
        Expanded(
          child: RecordControlButton(
            icon: Icons.stop,
            label: 'Stop',
            enabled: state.canStop,
            onPressed: notifier.stop,
          ),
        ),
      ],
    );
  }

  Widget _buildPausedControls(RecordingNotifier notifier, RecordingState state) {
    return Row(
      children: [
        const Expanded(child: SizedBox.shrink()),
        Expanded(
          child: RecordControlButton(
            icon: Icons.play_arrow,
            label: 'Resume',
            enabled: state.canResume,
            onPressed: notifier.resume,
          ),
        ),
        Expanded(
          child: RecordControlButton(
            icon: Icons.stop,
            label: 'Stop',
            enabled: state.canStop,
            onPressed: notifier.stop,
          ),
        ),
      ],
    );
  }
}

class RecordControlButton extends StatelessWidget {
  const RecordControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      children: [
        IconButton(
          onPressed: enabled ? onPressed : null,
          icon: Icon(icon),
          iconSize: 48,
        ),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

String formatRecordingDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String recordingPhaseLabel(RecordingPhase phase) {
  return switch (phase) {
    RecordingPhase.idle => 'Ready to record',
    RecordingPhase.recording => 'Recording',
    RecordingPhase.paused => 'Paused',
    RecordingPhase.stopped => 'Recording saved',
  };
}
