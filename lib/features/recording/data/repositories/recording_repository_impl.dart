import 'package:record_app/core/error/recording_exception.dart';
import 'package:record_app/features/recording/data/datasources/audio_recorder_datasource.dart';
import 'package:record_app/features/recording/domain/repositories/recording_repository.dart';

class RecordingRepositoryImpl implements RecordingRepository {
  RecordingRepositoryImpl(this._dataSource);

  final AudioRecorderDataSource _dataSource;

  @override
  Future<bool> hasPermission() => _dataSource.hasPermission();

  @override
  Future<void> start({required String filePath}) async {
    await _dataSource.start(filePath: filePath);
  }

  @override
  Future<void> pause() => _dataSource.pause();

  @override
  Future<void> resume() => _dataSource.resume();

  @override
  Future<String> stop() async {
    final path = await _dataSource.stop();
    if (path == null || path.isEmpty) {
      throw const RecordingException('Recording file path is empty.');
    }
    return path;
  }
}
