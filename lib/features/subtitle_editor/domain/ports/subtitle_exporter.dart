abstract interface class SubtitleExporter {
  /// Hands [content] to the OS share sheet as a file named [fileName].
  Future<void> share({
    required String fileName,
    required String content,
    String mimeType = 'application/x-subrip',
  });
}
