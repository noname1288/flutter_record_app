class RecordingException implements Exception {
  const RecordingException(this.message);

  final String message;

  @override
  String toString() => 'RecordingException: $message';
}
