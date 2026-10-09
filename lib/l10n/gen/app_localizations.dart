import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'ترجمان'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In ar, this message translates to:
  /// **'شاهد أي فيديو بالعربي، حتى بدون إنترنت.'**
  String get tagline;

  /// No description provided for @libraryTitle.
  ///
  /// In ar, this message translates to:
  /// **'مكتبتي'**
  String get libraryTitle;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'مكتبتك فارغة'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'أضف أول فيديو وشاهده بالعربي.'**
  String get libraryEmptyBody;

  /// No description provided for @addVideo.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فيديو'**
  String get addVideo;

  /// No description provided for @filterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get filterAll;

  /// No description provided for @filterReady.
  ///
  /// In ar, this message translates to:
  /// **'جاهز'**
  String get filterReady;

  /// No description provided for @filterProcessing.
  ///
  /// In ar, this message translates to:
  /// **'قيد المعالجة'**
  String get filterProcessing;

  /// No description provided for @statusReadyOffline.
  ///
  /// In ar, this message translates to:
  /// **'جاهز بدون إنترنت'**
  String get statusReadyOffline;

  /// No description provided for @statusProcessing.
  ///
  /// In ar, this message translates to:
  /// **'قيد المعالجة'**
  String get statusProcessing;

  /// No description provided for @statusOnline.
  ///
  /// In ar, this message translates to:
  /// **'أونلاين'**
  String get statusOnline;

  /// No description provided for @statusFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل'**
  String get statusFailed;

  /// No description provided for @noSubtitlesTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ترجمة بعد'**
  String get noSubtitlesTitle;

  /// No description provided for @noSubtitlesBody.
  ///
  /// In ar, this message translates to:
  /// **'أضف ملف ترجمة SRT أو VTT لتظهر فوق الفيديو.'**
  String get noSubtitlesBody;

  /// No description provided for @attachSubtitles.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ملف ترجمة'**
  String get attachSubtitles;

  /// No description provided for @subtitleStyle.
  ///
  /// In ar, this message translates to:
  /// **'نمط الترجمة'**
  String get subtitleStyle;

  /// No description provided for @size.
  ///
  /// In ar, this message translates to:
  /// **'الحجم'**
  String get size;

  /// No description provided for @colour.
  ///
  /// In ar, this message translates to:
  /// **'اللون'**
  String get colour;

  /// No description provided for @background.
  ///
  /// In ar, this message translates to:
  /// **'الخلفية'**
  String get background;

  /// No description provided for @position.
  ///
  /// In ar, this message translates to:
  /// **'المكان'**
  String get position;

  /// No description provided for @bgBox.
  ///
  /// In ar, this message translates to:
  /// **'صندوق'**
  String get bgBox;

  /// No description provided for @bgOutline.
  ///
  /// In ar, this message translates to:
  /// **'حدود'**
  String get bgOutline;

  /// No description provided for @bgNone.
  ///
  /// In ar, this message translates to:
  /// **'بدون'**
  String get bgNone;

  /// No description provided for @posBottom.
  ///
  /// In ar, this message translates to:
  /// **'أسفل'**
  String get posBottom;

  /// No description provided for @posTop.
  ///
  /// In ar, this message translates to:
  /// **'أعلى'**
  String get posTop;

  /// No description provided for @preview.
  ///
  /// In ar, this message translates to:
  /// **'هكذا ستظهر الترجمة'**
  String get preview;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @deleteVideoTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الفيديو؟'**
  String get deleteVideoTitle;

  /// No description provided for @deleteVideoBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف الفيديو وترجمته من جهازك.'**
  String get deleteVideoBody;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @videoImported.
  ///
  /// In ar, this message translates to:
  /// **'بدون ترجمة'**
  String get videoImported;

  /// No description provided for @cuesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} سطر'**
  String cuesCount(int count);

  /// No description provided for @errUnsupported.
  ///
  /// In ar, this message translates to:
  /// **'هذا الملف غير مدعوم. جرّب ملف SRT أو VTT بترميز UTF-8.'**
  String get errUnsupported;

  /// No description provided for @errStorage.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الوصول للملف. تأكد من المساحة والصلاحيات.'**
  String get errStorage;

  /// No description provided for @errNetwork.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت.'**
  String get errNetwork;

  /// No description provided for @errModel.
  ///
  /// In ar, this message translates to:
  /// **'حمّل النموذج المطلوب أولاً.'**
  String get errModel;

  /// No description provided for @errUnknown.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ. حاول مرة أخرى.'**
  String get errUnknown;

  /// No description provided for @playbackError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تشغيل الفيديو'**
  String get playbackError;

  /// No description provided for @speed.
  ///
  /// In ar, this message translates to:
  /// **'السرعة'**
  String get speed;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
