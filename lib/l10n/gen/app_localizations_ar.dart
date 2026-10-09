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
      'هذا الملف غير مدعوم. جرّب ملف SRT أو VTT بترميز UTF-8.';

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
}
