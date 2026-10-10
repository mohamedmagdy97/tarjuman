// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ترجمان';

  @override
  String get tagline => 'شاهد أي فيديو بالعربي، حتى بدون إنترنت.';

  @override
  String get libraryTitle => 'مكتبتي';

  @override
  String get libraryEmptyTitle => 'مكتبتك فارغة';

  @override
  String get libraryEmptyBody => 'أضف أول فيديو وشاهده بالعربي.';

  @override
  String get addVideo => 'إضافة فيديو';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterReady => 'جاهز';

  @override
  String get filterProcessing => 'قيد المعالجة';

  @override
  String get statusReadyOffline => 'جاهز بدون إنترنت';

  @override
  String get statusProcessing => 'قيد المعالجة';

  @override
  String get statusOnline => 'أونلاين';

  @override
  String get statusFailed => 'فشل';

  @override
  String get noSubtitlesTitle => 'لا توجد ترجمة بعد';

  @override
  String get noSubtitlesBody => 'أضف ملف ترجمة SRT أو VTT لتظهر فوق الفيديو.';

  @override
  String get attachSubtitles => 'إضافة ملف ترجمة';

  @override
  String get subtitleStyle => 'نمط الترجمة';

  @override
  String get size => 'الحجم';

  @override
  String get colour => 'اللون';

  @override
  String get background => 'الخلفية';

  @override
  String get position => 'المكان';

  @override
  String get bgBox => 'صندوق';

  @override
  String get bgOutline => 'حدود';

  @override
  String get bgNone => 'بدون';

  @override
  String get posBottom => 'أسفل';

  @override
  String get posTop => 'أعلى';

  @override
  String get preview => 'هكذا ستظهر الترجمة';

  @override
  String get delete => 'حذف';

  @override
  String get deleteVideoTitle => 'حذف الفيديو؟';

  @override
  String get deleteVideoBody => 'سيُحذف الفيديو وترجمته من جهازك.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get videoImported => 'بدون ترجمة';

  @override
  String cuesCount(int count) {
    return '$count سطر';
  }

  @override
  String get errUnsupported =>
      'تعذّرت قراءة الملف كفيديو أو صوت. جرّب ملفًا آخر.';

  @override
  String get errStorage => 'تعذّر الوصول للملف. تأكد من المساحة والصلاحيات.';

  @override
  String get errNetwork => 'لا يوجد اتصال بالإنترنت.';

  @override
  String get errModel => 'حمّل النموذج المطلوب أولاً.';

  @override
  String get errUnknown => 'حدث خطأ. حاول مرة أخرى.';

  @override
  String get playbackError => 'تعذّر تشغيل الفيديو';

  @override
  String get speed => 'السرعة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get setupTitle => 'ترجمة الفيديو';

  @override
  String get modeTitle => 'طريقة الترجمة';

  @override
  String get modePrepare => 'جهّز ثم شاهد';

  @override
  String get modeLive => 'مباشرة أثناء التشغيل';

  @override
  String get modePrepareHint => 'تُحفظ الترجمة وتعمل بدون إنترنت لاحقًا.';

  @override
  String get modeLiveHint =>
      'تظهر أثناء المشاهدة وقد تتأخر بضع ثوانٍ، ولا تُحفظ.';

  @override
  String get engineTitle => 'مكان المعالجة';

  @override
  String get engineOffline => 'على الجهاز';

  @override
  String get engineOfflineHint => 'الصوت لا يغادر هاتفك';

  @override
  String get engineOnline => 'عبر الإنترنت';

  @override
  String get engineOnlineHint => 'يُرسل الصوت إلى خدمة خارجية بعد موافقتك';

  @override
  String get modelsReady =>
      'النماذج جاهزة: التعرف على الكلام والترجمة للعربية.';

  @override
  String get modelsMissing => 'تحتاج تحميل نماذج الترجمة أولاً.';

  @override
  String get manageModels => 'إدارة النماذج';

  @override
  String get startTranslation => 'ابدأ الترجمة';

  @override
  String get onlineSetupNeeded =>
      'فعّل الترجمة عبر الإنترنت وأضف المفتاح من الإعدادات.';

  @override
  String get processingTitle => 'جارٍ الترجمة';

  @override
  String get overallProgress => 'التقدم الكلي';

  @override
  String get stagePreparing => 'التجهيز';

  @override
  String get stageExtract => 'استخراج الصوت';

  @override
  String get stageTranscribe => 'التعرف على الكلام';

  @override
  String get stageTranslate => 'الترجمة إلى العربية';

  @override
  String remainingTime(String time) {
    return 'متبقي نحو $time';
  }

  @override
  String get progressSaved => 'يُحفظ تقدمك تلقائيًا ويكمل من حيث توقف.';

  @override
  String get watchNow => 'شاهد الآن';

  @override
  String get processingDone => 'اكتملت الترجمة';

  @override
  String get resume => 'استكمال';

  @override
  String get processingFailed => 'توقفت المعالجة';

  @override
  String get processingCancelled => 'تم الإيقاف. تقدمك محفوظ ويمكنك الاستكمال.';

  @override
  String get modelsTitle => 'النماذج';

  @override
  String get speechModels => 'التعرف على الكلام';

  @override
  String get translationModels => 'الترجمة';

  @override
  String get download => 'تحميل';

  @override
  String get installed => 'مثبّت';

  @override
  String sizeMb(int mb) {
    return '$mb ميجا';
  }

  @override
  String get downloading => 'جارٍ التحميل';

  @override
  String get modelsDownloadFailed =>
      'تعذّر التحميل. تأكد من الاتصال وحاول مجددًا.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get themeTitle => 'المظهر';

  @override
  String get themeSystem => 'تلقائي';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeLight => 'فاتح';

  @override
  String get onlineSection => 'المعالجة عبر الإنترنت';

  @override
  String get onlineConsentTitle => 'الترجمة عبر الإنترنت';

  @override
  String get onlineConsentBody =>
      'يُرسل صوت الفيديو إلى المزوّد الذي تختاره أدناه بعد موافقتك. المعالجة على الجهاز تبقى الأساس.';

  @override
  String get apiKeyLabel => 'مفتاح OpenAI API';

  @override
  String get speechProviderTitle => 'مزوّد تحويل الكلام إلى نص';

  @override
  String get translationProviderTitle => 'مزوّد الترجمة';

  @override
  String apiKeyOf(String provider) {
    return 'مفتاح $provider API';
  }

  @override
  String get getApiKey => 'احصل على مفتاح';

  @override
  String get modelOverride => 'اسم النموذج (اختياري)';

  @override
  String get modelOverrideHint =>
      'اتركه فارغًا للافتراضي. غيّره إذا بدّل المزوّد أسماء نماذجه.';

  @override
  String get noKeyNeeded => 'لا يحتاج مفتاحًا';

  @override
  String get errRateLimited =>
      'تم الوصول إلى حد المزوّد أو الحصة. انتظر قليلًا أو اختر مزوّدًا آخر من الإعدادات.';

  @override
  String get apiKeySaved => 'تم حفظ المفتاح';

  @override
  String get save => 'حفظ';

  @override
  String get liveTranslating => 'جارٍ الترجمة…';

  @override
  String get errOnlineNotConfigured =>
      'فعّل الترجمة عبر الإنترنت وأضف مفتاح API من الإعدادات.';

  @override
  String get liveHint =>
      'الترجمة المباشرة لا تُحفظ. استخدم «جهّز ثم شاهد» لحفظها.';

  @override
  String get translateVideo => 'ترجمة هذا الفيديو';

  @override
  String get settings => 'الإعدادات';

  @override
  String get showOriginal => 'إظهار النص الإنجليزي فوق العربي';

  @override
  String get editSubtitles => 'تعديل الترجمة';

  @override
  String get exportSrt => 'تصدير SRT';

  @override
  String get exportBoth => 'مع النص الإنجليزي';

  @override
  String get searchCues => 'ابحث في الترجمة';

  @override
  String get editCueTitle => 'تعديل السطر';

  @override
  String get edited => 'معدّل';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String linesCount(int count) {
    return '$count سطر';
  }

  @override
  String get addFromDevice => 'من الجهاز';

  @override
  String get addFromLink => 'من رابط مباشر';

  @override
  String get linkTitle => 'رابط الفيديو';

  @override
  String get linkHint => 'رابط مباشر لملف فيديو أو صوت';

  @override
  String get linkDownload => 'تنزيل وإضافة';

  @override
  String get linkNote =>
      'روابط الملفات المباشرة فقط. روابط يوتيوب وأمثالها غير مدعومة.';

  @override
  String get downloadingVideo => 'جارٍ تنزيل الفيديو';

  @override
  String get errLink => 'تعذّر تنزيل الرابط. تأكد أنه رابط مباشر لملف.';

  @override
  String get saveEdit => 'حفظ';

  @override
  String get aboutSection => 'عن التطبيق';

  @override
  String get licenses => 'التراخيص مفتوحة المصدر';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String versionLabel(String version) {
    return 'الإصدار $version';
  }

  @override
  String get errSubtitle =>
      'ملف الترجمة غير صالح. اختر ملف SRT أو VTT بترميز UTF-8.';

  @override
  String get technicalDetails => 'تفاصيل تقنية';

  @override
  String get translateThisVideo => 'ترجمة هذا الفيديو';

  @override
  String get orAddSubtitleFile => 'أو أضف ملف ترجمة جاهزًا';

  @override
  String get addFromGallery => 'من معرض الفيديو';

  @override
  String get filterFavorites => 'المفضلة';

  @override
  String get addFavorite => 'إضافة للمفضلة';

  @override
  String get removeFavorite => 'إزالة من المفضلة';

  @override
  String get audioTrack => 'مسار الصوت';

  @override
  String get embeddedSubtitles => 'ترجمة مدمجة في الملف';

  @override
  String get subtitlesOff => 'إيقاف';

  @override
  String get loopAB => 'تكرار مقطع (أ-ب)';

  @override
  String get tracks => 'المسارات';

  @override
  String get studyMode => 'وضع المذاكرة';

  @override
  String get previousSentence => 'الجملة السابقة';

  @override
  String get nextSentence => 'الجملة التالية';

  @override
  String get repeatSentence => 'كرّر الجملة';

  @override
  String get tapAWord => 'اضغط على أي كلمة لترى معناها';

  @override
  String get saveWord => 'حفظ الكلمة';

  @override
  String get wordSaved => 'تم الحفظ';

  @override
  String get myVocabulary => 'كلماتي';

  @override
  String get vocabularyEmpty => 'لم تحفظ كلمات بعد';

  @override
  String get vocabularyEmptyBody =>
      'أثناء المشاهدة افتح وضع المذاكرة واضغط على أي كلمة لحفظها.';

  @override
  String get translatingWord => 'جارٍ الترجمة…';

  @override
  String get wordNeedsModels =>
      'حمّل نموذج الترجمة للغة أولاً من شاشة النماذج.';

  @override
  String get deleteWord => 'حذف الكلمة';

  @override
  String get subtitleTiming => 'توقيت الترجمة';

  @override
  String get subtitleLater => 'أبطأ';

  @override
  String get subtitleEarlier => 'أسرع';

  @override
  String get resetTiming => 'إعادة الضبط';

  @override
  String seconds(String value) {
    return '$value ث';
  }

  @override
  String get rotateScreen => 'تدوير الشاشة';

  @override
  String get sourceLanguageTitle => 'لغة كلام الفيديو';

  @override
  String get recommendedForDevice => 'موصى به لجهازك';

  @override
  String get multilingualModel => 'متعدد اللغات';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get start => 'ابدأ';

  @override
  String get onb1Title => 'ترجمة عربية لأي فيديو إنجليزي';

  @override
  String get onb1Body =>
      'أضف فيديو من هاتفك أو من رابط مباشر، ويظهر لك الكلام مترجمًا بالعربية فوق الصورة.';

  @override
  String get onb2Title => 'على جهازك، بدون إنترنت';

  @override
  String get onb2Body =>
      'المعالجة تتم على الهاتف فلا يغادر الصوت جهازك. اختر «جهّز ثم شاهد» لتحفظ الترجمة وتعيد مشاهدتها.';

  @override
  String get onb3Title => 'جهّز التطبيق مرة واحدة';

  @override
  String get onb3Body =>
      'نحمّل نماذج التعرف على الكلام والترجمة (نحو ١٥٠ إلى ٢٥٠ ميجابايت). يفضَّل أن تكون على واي فاي. يمكنك أيضًا تخطيها وتحميلها لاحقًا من شاشة النماذج.';

  @override
  String get onbDownloadNow => 'حمّل النماذج الآن';

  @override
  String get onbModelsDone => 'كل شيء جاهز. اضغط ابدأ.';

  @override
  String onbDownloading(int step, int total) {
    return 'جارٍ تحميل النموذج $step من $total…';
  }

  @override
  String notificationProgress(int percent) {
    return '$percent٪ مكتمل';
  }

  @override
  String get glossaryTitle => 'قاموس المصطلحات';

  @override
  String get glossaryEmpty => 'لا توجد مصطلحات';

  @override
  String get glossaryHint =>
      'أضف مصطلحات إنجليزية وما تريدها أن تُترجم به، فتُطبَّق على الترجمات القادمة (ميزة تجريبية).';

  @override
  String get addTerm => 'إضافة مصطلح';

  @override
  String get sourceTerm => 'المصطلح بلغة الفيديو';

  @override
  String get arabicTerm => 'الترجمة المطلوبة';

  @override
  String get retranslateOnline => 'أعد ترجمة السطر أونلاين';

  @override
  String get retranslateNeedsOnline =>
      'فعّل الترجمة عبر الإنترنت وأضف المفتاح من الإعدادات.';

  @override
  String get reviewTitle => 'مراجعة الكلمات';

  @override
  String get reviewDone => 'خلّصت مراجعة اليوم';

  @override
  String reviewDoneBody(int count) {
    return 'راجعت $count كلمة. ارجع لاحقًا لمراجعات جديدة.';
  }

  @override
  String reviewRemaining(int count) {
    return 'المتبقي: $count';
  }

  @override
  String get showAnswer => 'أظهر المعنى';

  @override
  String get gradeAgain => 'نسيت';

  @override
  String get gradeHard => 'صعب';

  @override
  String get gradeGood => 'جيد';

  @override
  String get gradeEasy => 'سهل';

  @override
  String get pronounce => 'نطق الكلمة';

  @override
  String get startReview => 'ابدأ المراجعة';

  @override
  String dueToday(int count) {
    return 'للمراجعة الآن: $count';
  }

  @override
  String get exportWords => 'تصدير الكلمات (CSV)';

  @override
  String get saveSentence => 'حفظ الجملة';

  @override
  String get sentenceSaved => 'تم حفظ الجملة';

  @override
  String get storageTitle => 'المساحة';

  @override
  String get storageVideos => 'الفيديوهات';

  @override
  String get storageModels => 'النماذج';

  @override
  String get storageTemp => 'ملفات مؤقتة';

  @override
  String get storageTotal => 'الإجمالي';

  @override
  String get clearTemp => 'مسح الملفات المؤقتة';

  @override
  String get storageVideosList => 'الفيديوهات حسب الحجم';

  @override
  String freedSpace(String size) {
    return 'تم تحرير $size';
  }

  @override
  String get storageEntry => 'المساحة والتخزين';

  @override
  String get backupWords => 'نسخة احتياطية للكلمات (JSON)';

  @override
  String get restoreWords => 'استعادة الكلمات من نسخة';

  @override
  String wordsRestored(int count) {
    return 'تمت إضافة $count كلمة';
  }

  @override
  String get invalidBackup => 'ملف النسخة الاحتياطية غير صالح.';

  @override
  String get searchLibrary => 'ابحث في الفيديوهات والترجمات';

  @override
  String get continueWatching => 'أكمل المشاهدة';

  @override
  String get inSubtitles => 'في الترجمات';

  @override
  String get sleepTimer => 'مؤقت النوم';

  @override
  String get sleepOff => 'إيقاف المؤقت';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get watchWhileTranslating => 'شاهد الآن أثناء الترجمة';

  @override
  String get detectLanguage => 'كشف اللغة تلقائيًا';

  @override
  String languageDetected(String name) {
    return 'تم كشف اللغة: $name';
  }

  @override
  String get errLanguageUnsupported =>
      'اللغة المكتشفة غير مدعومة للترجمة حاليًا.';

  @override
  String get detectNeedsModel =>
      'حمّل نموذج الكلام متعدد اللغات أولاً لكشف اللغة.';

  @override
  String get transcriptTitle => 'النص الكامل';

  @override
  String get copyAll => 'نسخ الكل';

  @override
  String get shareText => 'مشاركة كنص';

  @override
  String get copied => 'تم النسخ';
}
