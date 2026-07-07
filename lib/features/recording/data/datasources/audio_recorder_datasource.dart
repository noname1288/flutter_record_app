import 'package:record/record.dart';

class AudioRecorderDataSource {
  AudioRecorderDataSource() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<void> start({required String filePath}) {
    return _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: filePath,
    );
  }

  Future<void> pause() => _recorder.pause();

  Future<void> resume() => _recorder.resume();

  Future<String?> stop() => _recorder.stop();

  Future<void> dispose() => _recorder.dispose();
}
