/// Gets a downloaded file out of the app's private storage.
abstract interface class MediaExporter {
  /// Copies the file into the phone's public Movies/Music folder so the
  /// gallery and file managers see it. False when the platform can't do it
  /// silently (callers fall back to [shareFile]).
  Future<bool> saveToDevice({required String path, required String name});

  /// Opens the system share sheet ("Save to Files", Drive, WhatsApp...).
  Future<void> shareFile({required String path, required String name});
}
