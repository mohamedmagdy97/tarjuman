// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Tarjuman';

  @override
  String get tagline => 'Watch any video in Arabic, even offline.';

  @override
  String get libraryTitle => 'My library';

  @override
  String get libraryEmptyTitle => 'Your library is empty';

  @override
  String get libraryEmptyBody => 'Add your first video and watch it in Arabic.';

  @override
  String get addVideo => 'Add video';

  @override
  String get filterAll => 'All';

  @override
  String get filterReady => 'Ready';

  @override
  String get filterProcessing => 'Processing';

  @override
  String get statusReadyOffline => 'Ready offline';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusFailed => 'Failed';

  @override
  String get noSubtitlesTitle => 'No subtitles yet';

  @override
  String get noSubtitlesBody =>
      'Add an SRT or VTT file to show it over the video.';

  @override
  String get attachSubtitles => 'Add subtitle file';

  @override
  String get subtitleStyle => 'Subtitle style';

  @override
  String get size => 'Size';

  @override
  String get colour => 'Colour';

  @override
  String get background => 'Background';

  @override
  String get position => 'Position';

  @override
  String get bgBox => 'Box';

  @override
  String get bgOutline => 'Outline';

  @override
  String get bgNone => 'None';

  @override
  String get posBottom => 'Bottom';

  @override
  String get posTop => 'Top';

  @override
  String get preview => 'This is how subtitles will look';

  @override
  String get delete => 'Delete';

  @override
  String get deleteVideoTitle => 'Delete video?';

  @override
  String get deleteVideoBody =>
      'The video and its subtitles will be removed from this device.';

  @override
  String get cancel => 'Cancel';

  @override
  String get videoImported => 'No subtitles';

  @override
  String cuesCount(int count) {
    return '$count lines';
  }

  @override
  String get errUnsupported =>
      'This file isn\'t supported. Try an SRT or VTT file in UTF-8.';

  @override
  String get errStorage =>
      'Couldn\'t access the file. Check storage and permissions.';

  @override
  String get errNetwork => 'No internet connection.';

  @override
  String get errModel => 'Download the required model first.';

  @override
  String get errUnknown => 'Something went wrong. Try again.';

  @override
  String get playbackError => 'Couldn\'t play this video';

  @override
  String get speed => 'Speed';

  @override
  String get retry => 'Retry';

  @override
  String get setupTitle => 'Translate video';

  @override
  String get modeTitle => 'Translation mode';

  @override
  String get modePrepare => 'Prepare, then watch';

  @override
  String get modeLive => 'Live while playing';

  @override
  String get modePrepareHint => 'Subtitles are saved and work offline later.';

  @override
  String get modeLiveHint =>
      'Appear while you watch, may lag a few seconds, and aren\'t saved.';

  @override
  String get engineTitle => 'Where to process';

  @override
  String get engineOffline => 'On this device';

  @override
  String get engineOfflineHint => 'Audio never leaves your phone';

  @override
  String get engineOnline => 'Online';

  @override
  String get engineOnlineHint =>
      'Audio is sent to an external service after you consent';

  @override
  String get modelsReady =>
      'Models ready: speech recognition and Arabic translation.';

  @override
  String get modelsMissing => 'Download the translation models first.';

  @override
  String get manageModels => 'Manage models';

  @override
  String get startTranslation => 'Start translation';

  @override
  String get onlineSetupNeeded =>
      'Enable online translation and add your key in Settings.';

  @override
  String get processingTitle => 'Translating';

  @override
  String get overallProgress => 'Overall progress';

  @override
  String get stagePreparing => 'Preparing';

  @override
  String get stageExtract => 'Extracting audio';

  @override
  String get stageTranscribe => 'Recognising speech';

  @override
  String get stageTranslate => 'Translating to Arabic';

  @override
  String remainingTime(String time) {
    return 'About $time left';
  }

  @override
  String get progressSaved =>
      'Progress is saved automatically and resumes where it stopped.';

  @override
  String get watchNow => 'Watch now';

  @override
  String get processingDone => 'Translation complete';

  @override
  String get resume => 'Resume';

  @override
  String get processingFailed => 'Processing stopped';

  @override
  String get processingCancelled =>
      'Stopped. Your progress is saved and you can resume.';

  @override
  String get modelsTitle => 'Models';

  @override
  String get speechModels => 'Speech recognition';

  @override
  String get translationModels => 'Translation';

  @override
  String get download => 'Download';

  @override
  String get installed => 'Installed';

  @override
  String sizeMb(int mb) {
    return '$mb MB';
  }

  @override
  String get downloading => 'Downloading';

  @override
  String get modelsDownloadFailed =>
      'Download failed. Check your connection and try again.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeTitle => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get onlineSection => 'Online processing';

  @override
  String get onlineConsentTitle => 'Online translation';

  @override
  String get onlineConsentBody =>
      'Video audio is sent to OpenAI after your consent. On-device stays the default.';

  @override
  String get apiKeyLabel => 'OpenAI API key';

  @override
  String get apiKeySaved => 'Key saved';

  @override
  String get save => 'Save';

  @override
  String get liveTranslating => 'Translating…';

  @override
  String get errOnlineNotConfigured =>
      'Enable online translation and add an API key in Settings.';

  @override
  String get liveHint =>
      'Live subtitles aren\'t saved. Use Prepare to keep them.';

  @override
  String get translateVideo => 'Translate this video';

  @override
  String get settings => 'Settings';
}
