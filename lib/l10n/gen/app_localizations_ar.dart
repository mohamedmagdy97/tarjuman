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
      'يُرسل صوت الفيديو إلى خدمة OpenAI بعد موافقتك. المعالجة على الجهاز تبقى الأساس.';

  @override
  String get apiKeyLabel => 'مفتاح OpenAI API';

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
}
