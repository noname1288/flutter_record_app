abstract class RecordingRepository {
  Future<bool> hasPermission();

  Future<void> start({required String filePath});

  Future<void> pause();

  Future<void> resume();

  Future<String> stop();
}
