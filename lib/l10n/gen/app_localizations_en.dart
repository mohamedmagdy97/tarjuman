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
      'Couldn\'t read this file as video or audio. Try another file.';

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
      'Video audio is sent to the provider you choose below, after your consent. On-device stays the default.';

  @override
  String get apiKeyLabel => 'OpenAI API key';

  @override
  String get speechProviderTitle => 'Speech recognition provider';

  @override
  String get translationProviderTitle => 'Translation provider';

  @override
  String apiKeyOf(String provider) {
    return '$provider API key';
  }

  @override
  String get getApiKey => 'Get a key';

  @override
  String get modelOverride => 'Model name (optional)';

  @override
  String get modelOverrideHint =>
      'Leave empty for the default. Change it if the provider renames its models.';

  @override
  String get noKeyNeeded => 'No key needed';

  @override
  String get errRateLimited =>
      'The provider\'s limit or quota was reached. Wait a bit or pick another provider in Settings.';

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

  @override
  String get showOriginal => 'Show English above Arabic';

  @override
  String get editSubtitles => 'Edit subtitles';

  @override
  String get exportSrt => 'Export SRT';

  @override
  String get exportBoth => 'Include English';

  @override
  String get searchCues => 'Search subtitles';

  @override
  String get editCueTitle => 'Edit line';

  @override
  String get edited => 'Edited';

  @override
  String get noResults => 'No results';

  @override
  String linesCount(int count) {
    return '$count lines';
  }

  @override
  String get addFromDevice => 'From device';

  @override
  String get addFromLink => 'From a link';

  @override
  String get linkTitle => 'Video link';

  @override
  String get linkHint =>
      'Paste a video link: YouTube, Facebook, a website or a direct file';

  @override
  String get linkDownload => 'Download and add';

  @override
  String get linkNote =>
      'Works for public videos. Some sites block downloads, protected (DRM) or private videos won\'t work, and YouTube quality is limited.';

  @override
  String get downloadingVideo => 'Downloading video';

  @override
  String get saveEdit => 'Save';

  @override
  String get aboutSection => 'About';

  @override
  String get licenses => 'Open-source licenses';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get errSubtitle =>
      'Invalid subtitle file. Choose an SRT or VTT file in UTF-8.';

  @override
  String get technicalDetails => 'Technical details';

  @override
  String get translateThisVideo => 'Translate this video';

  @override
  String get orAddSubtitleFile => 'or add a ready subtitle file';

  @override
  String get addFromGallery => 'From video gallery';

  @override
  String get filterFavorites => 'Favorites';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get audioTrack => 'Audio track';

  @override
  String get embeddedSubtitles => 'Embedded subtitles';

  @override
  String get subtitlesOff => 'Off';

  @override
  String get loopAB => 'A-B repeat';

  @override
  String get tracks => 'Tracks';

  @override
  String get studyMode => 'Study mode';

  @override
  String get previousSentence => 'Previous sentence';

  @override
  String get nextSentence => 'Next sentence';

  @override
  String get repeatSentence => 'Repeat sentence';

  @override
  String get tapAWord => 'Tap any word to see its meaning';

  @override
  String get saveWord => 'Save word';

  @override
  String get wordSaved => 'Saved';

  @override
  String get myVocabulary => 'My words';

  @override
  String get vocabularyEmpty => 'No saved words yet';

  @override
  String get vocabularyEmptyBody =>
      'While watching, open Study mode and tap any word to save it.';

  @override
  String get translatingWord => 'Translating…';

  @override
  String get wordNeedsModels =>
      'Download the translation model for this language from the Models screen first.';

  @override
  String get deleteWord => 'Delete word';

  @override
  String get subtitleTiming => 'Subtitle timing';

  @override
  String get subtitleLater => 'Later';

  @override
  String get subtitleEarlier => 'Earlier';

  @override
  String get resetTiming => 'Reset';

  @override
  String seconds(String value) {
    return '$value s';
  }

  @override
  String get rotateScreen => 'Rotate screen';

  @override
  String get sourceLanguageTitle => 'Spoken language';

  @override
  String get recommendedForDevice => 'Recommended for your device';

  @override
  String get multilingualModel => 'Multilingual';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get start => 'Get started';

  @override
  String get onb1Title => 'Arabic subtitles for any English video';

  @override
  String get onb1Body =>
      'Add a video from your phone or a direct link and see the speech translated to Arabic over the picture.';

  @override
  String get onb2Title => 'On your device, offline';

  @override
  String get onb2Body =>
      'Processing happens on the phone, so audio never leaves it. Choose Prepare then watch to save subtitles and re-watch them.';

  @override
  String get onb3Title => 'Set up once';

  @override
  String get onb3Body =>
      'We download the speech and translation models (about 150 to 250 MB). Wi-Fi is best. You can also skip and get them later from the Models screen.';

  @override
  String get onbDownloadNow => 'Download models now';

  @override
  String get onbModelsDone => 'All set. Tap Get started.';

  @override
  String onbDownloading(int step, int total) {
    return 'Downloading model $step of $total…';
  }

  @override
  String notificationProgress(int percent) {
    return '$percent% complete';
  }

  @override
  String get glossaryTitle => 'Glossary';

  @override
  String get glossaryEmpty => 'No terms yet';

  @override
  String get glossaryHint =>
      'Add terms and how you want them translated. They apply to future translations (experimental).';

  @override
  String get addTerm => 'Add term';

  @override
  String get sourceTerm => 'Term in the video\'s language';

  @override
  String get arabicTerm => 'Wanted Arabic translation';

  @override
  String get retranslateOnline => 'Retranslate this line online';

  @override
  String get retranslateNeedsOnline =>
      'Enable online translation and add your key in Settings.';

  @override
  String get reviewTitle => 'Review words';

  @override
  String get reviewDone => 'Today\'s review is done';

  @override
  String reviewDoneBody(int count) {
    return 'You reviewed $count words. Come back later for more.';
  }

  @override
  String reviewRemaining(int count) {
    return 'Remaining: $count';
  }

  @override
  String get showAnswer => 'Show meaning';

  @override
  String get gradeAgain => 'Forgot';

  @override
  String get gradeHard => 'Hard';

  @override
  String get gradeGood => 'Good';

  @override
  String get gradeEasy => 'Easy';

  @override
  String get pronounce => 'Pronounce';

  @override
  String get startReview => 'Start review';

  @override
  String dueToday(int count) {
    return 'Due now: $count';
  }

  @override
  String get exportWords => 'Export words (CSV)';

  @override
  String get saveSentence => 'Save sentence';

  @override
  String get sentenceSaved => 'Sentence saved';

  @override
  String get storageTitle => 'Storage';

  @override
  String get storageVideos => 'Videos';

  @override
  String get storageModels => 'Models';

  @override
  String get storageTemp => 'Temporary files';

  @override
  String get storageTotal => 'Total';

  @override
  String get clearTemp => 'Clear temporary files';

  @override
  String get storageVideosList => 'Videos by size';

  @override
  String freedSpace(String size) {
    return 'Freed $size';
  }

  @override
  String get storageEntry => 'Storage';

  @override
  String get backupWords => 'Back up words (JSON)';

  @override
  String get restoreWords => 'Restore words from a backup';

  @override
  String wordsRestored(int count) {
    return 'Added $count words';
  }

  @override
  String get invalidBackup => 'Invalid backup file.';

  @override
  String get searchLibrary => 'Search videos and subtitles';

  @override
  String get continueWatching => 'Continue watching';

  @override
  String get inSubtitles => 'In subtitles';

  @override
  String get sleepTimer => 'Sleep timer';

  @override
  String get sleepOff => 'Turn off timer';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get watchWhileTranslating => 'Watch now while it translates';

  @override
  String get detectLanguage => 'Detect language';

  @override
  String languageDetected(String name) {
    return 'Detected: $name';
  }

  @override
  String get errLanguageUnsupported =>
      'The detected language isn\'t supported for translation yet.';

  @override
  String get detectNeedsModel =>
      'Download the multilingual speech model first to detect the language.';

  @override
  String get transcriptTitle => 'Full text';

  @override
  String get copyAll => 'Copy all';

  @override
  String get shareText => 'Share as text';

  @override
  String get copied => 'Copied';

  @override
  String get errInvalidLink =>
      'This doesn\'t look like a web address. Paste the full link, e.g. https://…';

  @override
  String get errNoVideo =>
      'No downloadable video was found on this page. Open the page, play the video, then pick it from the detected list.';

  @override
  String get errSiteRefused =>
      'The site refused the download (it may need a login, or blocks downloads).';

  @override
  String get errLink => 'Couldn\'t download this link.';

  @override
  String get browserHint => 'Type or paste a link';

  @override
  String get browserStart =>
      'Open a site, play the video, and the app detects it so you can download one or many.';

  @override
  String get browserDetected => 'Detected videos';

  @override
  String get browserNone =>
      'No video detected yet. Play the video on the page, then open this list again.';

  @override
  String get browserDownloadPage => 'Download this page\'s video';

  @override
  String browserDownloadSelected(int count) {
    return 'Download selected ($count)';
  }

  @override
  String browserAdded(int count) {
    return '$count added to downloads';
  }

  @override
  String get downloadsTitle => 'Downloads';

  @override
  String get downloadsEmpty => 'No downloads yet';

  @override
  String get downloadWaiting => 'Waiting';

  @override
  String get downloadOpen => 'Open';

  @override
  String get downloadRetry => 'Retry';

  @override
  String get downloadClearDone => 'Clear finished';

  @override
  String get downloadDone => 'Added to your library';

  @override
  String downloadFailedReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get autoSaveTitle => 'Also save downloads to the gallery';

  @override
  String get autoSaveBody =>
      'Keeps a copy in Movies/Tarjuman so other apps can see it. Uses extra storage.';

  @override
  String get saveToDevice => 'Save to device';

  @override
  String get shareFile => 'Share file';

  @override
  String get videoActions => 'Video actions';

  @override
  String get savedToDevice => 'Saved to Movies/Tarjuman';

  @override
  String get sharedInstead => 'Choose where to save the file';

  @override
  String get downloadSaved => 'Saved in gallery too';

  @override
  String get pasteLink => 'Paste link';

  @override
  String get downloadingNotificationTitle => 'Downloading videos';

  @override
  String downloadingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count downloads in progress',
      one: '1 download in progress',
    );
    return '$_temp0';
  }

  @override
  String get downloadFinishedTitle => 'Download finished';

  @override
  String get downloadFailedTitle => 'Download failed';

  @override
  String get videoGlossaryTitle => 'Glossary for this video';

  @override
  String get videoGlossaryHint =>
      'These terms apply only to this video and win over the general glossary. They affect new translations (re-run the translation to apply them to existing lines).';

  @override
  String needsReview(int count) {
    return 'Needs review ($count)';
  }

  @override
  String get speakerLabel => 'Speaker';

  @override
  String get issueUntranslated => 'Not translated';

  @override
  String get issueLatin => 'Mostly Latin letters';

  @override
  String get issueTooShort => 'Much shorter than the source';

  @override
  String get issueTooLong => 'Much longer than the source';

  @override
  String get issueFast => 'Too fast to read';

  @override
  String get issueRepeated => 'Same as the previous line';

  @override
  String get smartSpeed => 'Speed up silences';

  @override
  String get extractAudio => 'Extract audio (MP3)';

  @override
  String get extractingAudio => 'Converting to MP3…';

  @override
  String get audioSaved => 'MP3 saved to Music/Tarjuman';

  @override
  String get playlistsTitle => 'Playlists';

  @override
  String get playlistsEmpty => 'No playlists yet';

  @override
  String get playlistsEmptyBody =>
      'Group a series or course and it plays one episode after another, remembering where you stopped.';

  @override
  String get playlistName => 'Playlist name';

  @override
  String playlistCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count videos',
      one: '1 video',
      zero: 'Empty',
    );
    return '$_temp0';
  }

  @override
  String get playlistEmpty => 'This playlist is empty';

  @override
  String get playlistEmptyBody => 'Add videos with the button above.';

  @override
  String get playAll => 'Play all';

  @override
  String get removeFromPlaylist => 'Remove from playlist';

  @override
  String get addToPlaylist => 'Add to playlist';

  @override
  String get newPlaylist => 'New playlist';

  @override
  String get addedToPlaylist => 'Added to playlist';

  @override
  String get noVideosToAdd => 'All your videos are already here.';

  @override
  String addToPlaylistCount(int count) {
    return 'Add ($count)';
  }

  @override
  String get downloadWholeList => 'Download the whole playlist / channel';

  @override
  String get listingVideos => 'Reading the list…';

  @override
  String downloadAllBody(int count) {
    return '$count videos found (up to 50). They download in order and are grouped into one playlist in your library.';
  }

  @override
  String get audioOnly => 'Audio only (background)';

  @override
  String get nextEpisode => 'Next episode';
}
