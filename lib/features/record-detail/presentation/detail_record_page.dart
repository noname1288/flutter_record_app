import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_app/features/record-detail/presentation/widgets/controls_button_row.dart';
import 'package:record_app/features/recording/presentation/providers/recording_notifier.dart';

class DetailRecordPage extends ConsumerWidget {
  const DetailRecordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordingNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Record'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formatRecordingDuration(state.elapsed),
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(recordingPhaseLabel(state.phase)),
                      if (state.filePath != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          state.filePath!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          state.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Expanded(flex: 1, child: ControlsButtonRow()),
            ],
          ),
        ),
      ),
    );
  }
}
