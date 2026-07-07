import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_app/features/recording/data/datasources/audio_recorder_datasource.dart';
import 'package:record_app/features/recording/data/repositories/recording_repository_impl.dart';
import 'package:record_app/features/recording/domain/repositories/recording_repository.dart';

final audioRecorderDataSourceProvider = Provider<AudioRecorderDataSource>((ref) {
  final dataSource = AudioRecorderDataSource();
  ref.onDispose(dataSource.dispose);
  return dataSource;
});

final recordingRepositoryProvider = Provider<RecordingRepository>((ref) {
  return RecordingRepositoryImpl(ref.watch(audioRecorderDataSourceProvider));
});
