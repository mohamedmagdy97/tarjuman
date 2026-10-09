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
}
