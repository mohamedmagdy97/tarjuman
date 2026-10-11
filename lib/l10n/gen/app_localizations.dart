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
  /// **'تعذّرت قراءة الملف كفيديو أو صوت. جرّب ملفًا آخر.'**
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

  /// No description provided for @setupTitle.
  ///
  /// In ar, this message translates to:
  /// **'ترجمة الفيديو'**
  String get setupTitle;

  /// No description provided for @modeTitle.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الترجمة'**
  String get modeTitle;

  /// No description provided for @modePrepare.
  ///
  /// In ar, this message translates to:
  /// **'جهّز ثم شاهد'**
  String get modePrepare;

  /// No description provided for @modeLive.
  ///
  /// In ar, this message translates to:
  /// **'مباشرة أثناء التشغيل'**
  String get modeLive;

  /// No description provided for @modePrepareHint.
  ///
  /// In ar, this message translates to:
  /// **'تُحفظ الترجمة وتعمل بدون إنترنت لاحقًا.'**
  String get modePrepareHint;

  /// No description provided for @modeLiveHint.
  ///
  /// In ar, this message translates to:
  /// **'تظهر أثناء المشاهدة وقد تتأخر بضع ثوانٍ، ولا تُحفظ.'**
  String get modeLiveHint;

  /// No description provided for @engineTitle.
  ///
  /// In ar, this message translates to:
  /// **'مكان المعالجة'**
  String get engineTitle;

  /// No description provided for @engineOffline.
  ///
  /// In ar, this message translates to:
  /// **'على الجهاز'**
  String get engineOffline;

  /// No description provided for @engineOfflineHint.
  ///
  /// In ar, this message translates to:
  /// **'الصوت لا يغادر هاتفك'**
  String get engineOfflineHint;

  /// No description provided for @engineOnline.
  ///
  /// In ar, this message translates to:
  /// **'عبر الإنترنت'**
  String get engineOnline;

  /// No description provided for @engineOnlineHint.
  ///
  /// In ar, this message translates to:
  /// **'يُرسل الصوت إلى خدمة خارجية بعد موافقتك'**
  String get engineOnlineHint;

  /// No description provided for @modelsReady.
  ///
  /// In ar, this message translates to:
  /// **'النماذج جاهزة: التعرف على الكلام والترجمة للعربية.'**
  String get modelsReady;

  /// No description provided for @modelsMissing.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج تحميل نماذج الترجمة أولاً.'**
  String get modelsMissing;

  /// No description provided for @manageModels.
  ///
  /// In ar, this message translates to:
  /// **'إدارة النماذج'**
  String get manageModels;

  /// No description provided for @startTranslation.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الترجمة'**
  String get startTranslation;

  /// No description provided for @onlineSetupNeeded.
  ///
  /// In ar, this message translates to:
  /// **'فعّل الترجمة عبر الإنترنت وأضف المفتاح من الإعدادات.'**
  String get onlineSetupNeeded;

  /// No description provided for @processingTitle.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الترجمة'**
  String get processingTitle;

  /// No description provided for @overallProgress.
  ///
  /// In ar, this message translates to:
  /// **'التقدم الكلي'**
  String get overallProgress;

  /// No description provided for @stagePreparing.
  ///
  /// In ar, this message translates to:
  /// **'التجهيز'**
  String get stagePreparing;

  /// No description provided for @stageExtract.
  ///
  /// In ar, this message translates to:
  /// **'استخراج الصوت'**
  String get stageExtract;

  /// No description provided for @stageTranscribe.
  ///
  /// In ar, this message translates to:
  /// **'التعرف على الكلام'**
  String get stageTranscribe;

  /// No description provided for @stageTranslate.
  ///
  /// In ar, this message translates to:
  /// **'الترجمة إلى العربية'**
  String get stageTranslate;

  /// No description provided for @remainingTime.
  ///
  /// In ar, this message translates to:
  /// **'متبقي نحو {time}'**
  String remainingTime(String time);

  /// No description provided for @progressSaved.
  ///
  /// In ar, this message translates to:
  /// **'يُحفظ تقدمك تلقائيًا ويكمل من حيث توقف.'**
  String get progressSaved;

  /// No description provided for @watchNow.
  ///
  /// In ar, this message translates to:
  /// **'شاهد الآن'**
  String get watchNow;

  /// No description provided for @processingDone.
  ///
  /// In ar, this message translates to:
  /// **'اكتملت الترجمة'**
  String get processingDone;

  /// No description provided for @resume.
  ///
  /// In ar, this message translates to:
  /// **'استكمال'**
  String get resume;

  /// No description provided for @processingFailed.
  ///
  /// In ar, this message translates to:
  /// **'توقفت المعالجة'**
  String get processingFailed;

  /// No description provided for @processingCancelled.
  ///
  /// In ar, this message translates to:
  /// **'تم الإيقاف. تقدمك محفوظ ويمكنك الاستكمال.'**
  String get processingCancelled;

  /// No description provided for @modelsTitle.
  ///
  /// In ar, this message translates to:
  /// **'النماذج'**
  String get modelsTitle;

  /// No description provided for @speechModels.
  ///
  /// In ar, this message translates to:
  /// **'التعرف على الكلام'**
  String get speechModels;

  /// No description provided for @translationModels.
  ///
  /// In ar, this message translates to:
  /// **'الترجمة'**
  String get translationModels;

  /// No description provided for @download.
  ///
  /// In ar, this message translates to:
  /// **'تحميل'**
  String get download;

  /// No description provided for @installed.
  ///
  /// In ar, this message translates to:
  /// **'مثبّت'**
  String get installed;

  /// No description provided for @sizeMb.
  ///
  /// In ar, this message translates to:
  /// **'{mb} ميجا'**
  String sizeMb(int mb);

  /// No description provided for @downloading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل'**
  String get downloading;

  /// No description provided for @modelsDownloadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر التحميل. تأكد من الاتصال وحاول مجددًا.'**
  String get modelsDownloadFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @themeTitle.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get themeTitle;

  /// No description provided for @themeSystem.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get themeLight;

  /// No description provided for @onlineSection.
  ///
  /// In ar, this message translates to:
  /// **'المعالجة عبر الإنترنت'**
  String get onlineSection;

  /// No description provided for @onlineConsentTitle.
  ///
  /// In ar, this message translates to:
  /// **'الترجمة عبر الإنترنت'**
  String get onlineConsentTitle;

  /// No description provided for @onlineConsentBody.
  ///
  /// In ar, this message translates to:
  /// **'يُرسل صوت الفيديو إلى المزوّد الذي تختاره أدناه بعد موافقتك. المعالجة على الجهاز تبقى الأساس.'**
  String get onlineConsentBody;

  /// No description provided for @apiKeyLabel.
  ///
  /// In ar, this message translates to:
  /// **'مفتاح OpenAI API'**
  String get apiKeyLabel;

  /// No description provided for @speechProviderTitle.
  ///
  /// In ar, this message translates to:
  /// **'مزوّد تحويل الكلام إلى نص'**
  String get speechProviderTitle;

  /// No description provided for @translationProviderTitle.
  ///
  /// In ar, this message translates to:
  /// **'مزوّد الترجمة'**
  String get translationProviderTitle;

  /// No description provided for @apiKeyOf.
  ///
  /// In ar, this message translates to:
  /// **'مفتاح {provider} API'**
  String apiKeyOf(String provider);

  /// No description provided for @getApiKey.
  ///
  /// In ar, this message translates to:
  /// **'احصل على مفتاح'**
  String get getApiKey;

  /// No description provided for @modelOverride.
  ///
  /// In ar, this message translates to:
  /// **'اسم النموذج (اختياري)'**
  String get modelOverride;

  /// No description provided for @modelOverrideHint.
  ///
  /// In ar, this message translates to:
  /// **'اتركه فارغًا للافتراضي. غيّره إذا بدّل المزوّد أسماء نماذجه.'**
  String get modelOverrideHint;

  /// No description provided for @noKeyNeeded.
  ///
  /// In ar, this message translates to:
  /// **'لا يحتاج مفتاحًا'**
  String get noKeyNeeded;

  /// No description provided for @errRateLimited.
  ///
  /// In ar, this message translates to:
  /// **'تم الوصول إلى حد المزوّد أو الحصة. انتظر قليلًا أو اختر مزوّدًا آخر من الإعدادات.'**
  String get errRateLimited;

  /// No description provided for @apiKeySaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ المفتاح'**
  String get apiKeySaved;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @liveTranslating.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الترجمة…'**
  String get liveTranslating;

  /// No description provided for @errOnlineNotConfigured.
  ///
  /// In ar, this message translates to:
  /// **'فعّل الترجمة عبر الإنترنت وأضف مفتاح API من الإعدادات.'**
  String get errOnlineNotConfigured;

  /// No description provided for @liveHint.
  ///
  /// In ar, this message translates to:
  /// **'الترجمة المباشرة لا تُحفظ. استخدم «جهّز ثم شاهد» لحفظها.'**
  String get liveHint;

  /// No description provided for @translateVideo.
  ///
  /// In ar, this message translates to:
  /// **'ترجمة هذا الفيديو'**
  String get translateVideo;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @showOriginal.
  ///
  /// In ar, this message translates to:
  /// **'إظهار النص الإنجليزي فوق العربي'**
  String get showOriginal;

  /// No description provided for @editSubtitles.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الترجمة'**
  String get editSubtitles;

  /// No description provided for @exportSrt.
  ///
  /// In ar, this message translates to:
  /// **'تصدير SRT'**
  String get exportSrt;

  /// No description provided for @exportBoth.
  ///
  /// In ar, this message translates to:
  /// **'مع النص الإنجليزي'**
  String get exportBoth;

  /// No description provided for @searchCues.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في الترجمة'**
  String get searchCues;

  /// No description provided for @editCueTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل السطر'**
  String get editCueTitle;

  /// No description provided for @edited.
  ///
  /// In ar, this message translates to:
  /// **'معدّل'**
  String get edited;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResults;

  /// No description provided for @linesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} سطر'**
  String linesCount(int count);

  /// No description provided for @addFromDevice.
  ///
  /// In ar, this message translates to:
  /// **'من الجهاز'**
  String get addFromDevice;

  /// No description provided for @addFromLink.
  ///
  /// In ar, this message translates to:
  /// **'من رابط'**
  String get addFromLink;

  /// No description provided for @linkTitle.
  ///
  /// In ar, this message translates to:
  /// **'رابط الفيديو'**
  String get linkTitle;

  /// No description provided for @linkHint.
  ///
  /// In ar, this message translates to:
  /// **'الصق رابط فيديو: يوتيوب، فيسبوك، موقع، أو ملف مباشر'**
  String get linkHint;

  /// No description provided for @linkDownload.
  ///
  /// In ar, this message translates to:
  /// **'تنزيل وإضافة'**
  String get linkDownload;

  /// No description provided for @linkNote.
  ///
  /// In ar, this message translates to:
  /// **'يعمل مع الفيديوهات العامة. بعض المواقع تمنع التحميل، والفيديوهات الخاصة أو المحمية لن تعمل، وجودة يوتيوب محدودة.'**
  String get linkNote;

  /// No description provided for @downloadingVideo.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تنزيل الفيديو'**
  String get downloadingVideo;

  /// No description provided for @saveEdit.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get saveEdit;

  /// No description provided for @aboutSection.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutSection;

  /// No description provided for @licenses.
  ///
  /// In ar, this message translates to:
  /// **'التراخيص مفتوحة المصدر'**
  String get licenses;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @versionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String versionLabel(String version);

  /// No description provided for @errSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ملف الترجمة غير صالح. اختر ملف SRT أو VTT بترميز UTF-8.'**
  String get errSubtitle;

  /// No description provided for @technicalDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل تقنية'**
  String get technicalDetails;

  /// No description provided for @translateThisVideo.
  ///
  /// In ar, this message translates to:
  /// **'ترجمة هذا الفيديو'**
  String get translateThisVideo;

  /// No description provided for @orAddSubtitleFile.
  ///
  /// In ar, this message translates to:
  /// **'أو أضف ملف ترجمة جاهزًا'**
  String get orAddSubtitleFile;

  /// No description provided for @addFromGallery.
  ///
  /// In ar, this message translates to:
  /// **'من معرض الفيديو'**
  String get addFromGallery;

  /// No description provided for @filterFavorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get filterFavorites;

  /// No description provided for @addFavorite.
  ///
  /// In ar, this message translates to:
  /// **'إضافة للمفضلة'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من المفضلة'**
  String get removeFavorite;

  /// No description provided for @audioTrack.
  ///
  /// In ar, this message translates to:
  /// **'مسار الصوت'**
  String get audioTrack;

  /// No description provided for @embeddedSubtitles.
  ///
  /// In ar, this message translates to:
  /// **'ترجمة مدمجة في الملف'**
  String get embeddedSubtitles;

  /// No description provided for @subtitlesOff.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف'**
  String get subtitlesOff;

  /// No description provided for @loopAB.
  ///
  /// In ar, this message translates to:
  /// **'تكرار مقطع (أ-ب)'**
  String get loopAB;

  /// No description provided for @tracks.
  ///
  /// In ar, this message translates to:
  /// **'المسارات'**
  String get tracks;

  /// No description provided for @studyMode.
  ///
  /// In ar, this message translates to:
  /// **'وضع المذاكرة'**
  String get studyMode;

  /// No description provided for @previousSentence.
  ///
  /// In ar, this message translates to:
  /// **'الجملة السابقة'**
  String get previousSentence;

  /// No description provided for @nextSentence.
  ///
  /// In ar, this message translates to:
  /// **'الجملة التالية'**
  String get nextSentence;

  /// No description provided for @repeatSentence.
  ///
  /// In ar, this message translates to:
  /// **'كرّر الجملة'**
  String get repeatSentence;

  /// No description provided for @tapAWord.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على أي كلمة لترى معناها'**
  String get tapAWord;

  /// No description provided for @saveWord.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الكلمة'**
  String get saveWord;

  /// No description provided for @wordSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ'**
  String get wordSaved;

  /// No description provided for @myVocabulary.
  ///
  /// In ar, this message translates to:
  /// **'كلماتي'**
  String get myVocabulary;

  /// No description provided for @vocabularyEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لم تحفظ كلمات بعد'**
  String get vocabularyEmpty;

  /// No description provided for @vocabularyEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'أثناء المشاهدة افتح وضع المذاكرة واضغط على أي كلمة لحفظها.'**
  String get vocabularyEmptyBody;

  /// No description provided for @translatingWord.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الترجمة…'**
  String get translatingWord;

  /// No description provided for @wordNeedsModels.
  ///
  /// In ar, this message translates to:
  /// **'حمّل نموذج الترجمة للغة أولاً من شاشة النماذج.'**
  String get wordNeedsModels;

  /// No description provided for @deleteWord.
  ///
  /// In ar, this message translates to:
  /// **'حذف الكلمة'**
  String get deleteWord;

  /// No description provided for @subtitleTiming.
  ///
  /// In ar, this message translates to:
  /// **'توقيت الترجمة'**
  String get subtitleTiming;

  /// No description provided for @subtitleLater.
  ///
  /// In ar, this message translates to:
  /// **'أبطأ'**
  String get subtitleLater;

  /// No description provided for @subtitleEarlier.
  ///
  /// In ar, this message translates to:
  /// **'أسرع'**
  String get subtitleEarlier;

  /// No description provided for @resetTiming.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الضبط'**
  String get resetTiming;

  /// No description provided for @seconds.
  ///
  /// In ar, this message translates to:
  /// **'{value} ث'**
  String seconds(String value);

  /// No description provided for @rotateScreen.
  ///
  /// In ar, this message translates to:
  /// **'تدوير الشاشة'**
  String get rotateScreen;

  /// No description provided for @sourceLanguageTitle.
  ///
  /// In ar, this message translates to:
  /// **'لغة كلام الفيديو'**
  String get sourceLanguageTitle;

  /// No description provided for @recommendedForDevice.
  ///
  /// In ar, this message translates to:
  /// **'موصى به لجهازك'**
  String get recommendedForDevice;

  /// No description provided for @multilingualModel.
  ///
  /// In ar, this message translates to:
  /// **'متعدد اللغات'**
  String get multilingualModel;

  /// No description provided for @skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @start.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get start;

  /// No description provided for @onb1Title.
  ///
  /// In ar, this message translates to:
  /// **'ترجمة عربية لأي فيديو إنجليزي'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In ar, this message translates to:
  /// **'أضف فيديو من هاتفك أو من رابط مباشر، ويظهر لك الكلام مترجمًا بالعربية فوق الصورة.'**
  String get onb1Body;

  /// No description provided for @onb2Title.
  ///
  /// In ar, this message translates to:
  /// **'على جهازك، بدون إنترنت'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In ar, this message translates to:
  /// **'المعالجة تتم على الهاتف فلا يغادر الصوت جهازك. اختر «جهّز ثم شاهد» لتحفظ الترجمة وتعيد مشاهدتها.'**
  String get onb2Body;

  /// No description provided for @onb3Title.
  ///
  /// In ar, this message translates to:
  /// **'جهّز التطبيق مرة واحدة'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In ar, this message translates to:
  /// **'نحمّل نماذج التعرف على الكلام والترجمة (نحو ١٥٠ إلى ٢٥٠ ميجابايت). يفضَّل أن تكون على واي فاي. يمكنك أيضًا تخطيها وتحميلها لاحقًا من شاشة النماذج.'**
  String get onb3Body;

  /// No description provided for @onbDownloadNow.
  ///
  /// In ar, this message translates to:
  /// **'حمّل النماذج الآن'**
  String get onbDownloadNow;

  /// No description provided for @onbModelsDone.
  ///
  /// In ar, this message translates to:
  /// **'كل شيء جاهز. اضغط ابدأ.'**
  String get onbModelsDone;

  /// No description provided for @onbDownloading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحميل النموذج {step} من {total}…'**
  String onbDownloading(int step, int total);

  /// No description provided for @notificationProgress.
  ///
  /// In ar, this message translates to:
  /// **'{percent}٪ مكتمل'**
  String notificationProgress(int percent);

  /// No description provided for @glossaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'قاموس المصطلحات'**
  String get glossaryTitle;

  /// No description provided for @glossaryEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مصطلحات'**
  String get glossaryEmpty;

  /// No description provided for @glossaryHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف مصطلحات إنجليزية وما تريدها أن تُترجم به، فتُطبَّق على الترجمات القادمة (ميزة تجريبية).'**
  String get glossaryHint;

  /// No description provided for @addTerm.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مصطلح'**
  String get addTerm;

  /// No description provided for @sourceTerm.
  ///
  /// In ar, this message translates to:
  /// **'المصطلح بلغة الفيديو'**
  String get sourceTerm;

  /// No description provided for @arabicTerm.
  ///
  /// In ar, this message translates to:
  /// **'الترجمة المطلوبة'**
  String get arabicTerm;

  /// No description provided for @retranslateOnline.
  ///
  /// In ar, this message translates to:
  /// **'أعد ترجمة السطر أونلاين'**
  String get retranslateOnline;

  /// No description provided for @retranslateNeedsOnline.
  ///
  /// In ar, this message translates to:
  /// **'فعّل الترجمة عبر الإنترنت وأضف المفتاح من الإعدادات.'**
  String get retranslateNeedsOnline;

  /// No description provided for @reviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة الكلمات'**
  String get reviewTitle;

  /// No description provided for @reviewDone.
  ///
  /// In ar, this message translates to:
  /// **'خلّصت مراجعة اليوم'**
  String get reviewDone;

  /// No description provided for @reviewDoneBody.
  ///
  /// In ar, this message translates to:
  /// **'راجعت {count} كلمة. ارجع لاحقًا لمراجعات جديدة.'**
  String reviewDoneBody(int count);

  /// No description provided for @reviewRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي: {count}'**
  String reviewRemaining(int count);

  /// No description provided for @showAnswer.
  ///
  /// In ar, this message translates to:
  /// **'أظهر المعنى'**
  String get showAnswer;

  /// No description provided for @gradeAgain.
  ///
  /// In ar, this message translates to:
  /// **'نسيت'**
  String get gradeAgain;

  /// No description provided for @gradeHard.
  ///
  /// In ar, this message translates to:
  /// **'صعب'**
  String get gradeHard;

  /// No description provided for @gradeGood.
  ///
  /// In ar, this message translates to:
  /// **'جيد'**
  String get gradeGood;

  /// No description provided for @gradeEasy.
  ///
  /// In ar, this message translates to:
  /// **'سهل'**
  String get gradeEasy;

  /// No description provided for @pronounce.
  ///
  /// In ar, this message translates to:
  /// **'نطق الكلمة'**
  String get pronounce;

  /// No description provided for @startReview.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ المراجعة'**
  String get startReview;

  /// No description provided for @dueToday.
  ///
  /// In ar, this message translates to:
  /// **'للمراجعة الآن: {count}'**
  String dueToday(int count);

  /// No description provided for @exportWords.
  ///
  /// In ar, this message translates to:
  /// **'تصدير الكلمات (CSV)'**
  String get exportWords;

  /// No description provided for @saveSentence.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الجملة'**
  String get saveSentence;

  /// No description provided for @sentenceSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الجملة'**
  String get sentenceSaved;

  /// No description provided for @storageTitle.
  ///
  /// In ar, this message translates to:
  /// **'المساحة'**
  String get storageTitle;

  /// No description provided for @storageVideos.
  ///
  /// In ar, this message translates to:
  /// **'الفيديوهات'**
  String get storageVideos;

  /// No description provided for @storageModels.
  ///
  /// In ar, this message translates to:
  /// **'النماذج'**
  String get storageModels;

  /// No description provided for @storageTemp.
  ///
  /// In ar, this message translates to:
  /// **'ملفات مؤقتة'**
  String get storageTemp;

  /// No description provided for @storageTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get storageTotal;

  /// No description provided for @clearTemp.
  ///
  /// In ar, this message translates to:
  /// **'مسح الملفات المؤقتة'**
  String get clearTemp;

  /// No description provided for @storageVideosList.
  ///
  /// In ar, this message translates to:
  /// **'الفيديوهات حسب الحجم'**
  String get storageVideosList;

  /// No description provided for @freedSpace.
  ///
  /// In ar, this message translates to:
  /// **'تم تحرير {size}'**
  String freedSpace(String size);

  /// No description provided for @storageEntry.
  ///
  /// In ar, this message translates to:
  /// **'المساحة والتخزين'**
  String get storageEntry;

  /// No description provided for @backupWords.
  ///
  /// In ar, this message translates to:
  /// **'نسخة احتياطية للكلمات (JSON)'**
  String get backupWords;

  /// No description provided for @restoreWords.
  ///
  /// In ar, this message translates to:
  /// **'استعادة الكلمات من نسخة'**
  String get restoreWords;

  /// No description provided for @wordsRestored.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة {count} كلمة'**
  String wordsRestored(int count);

  /// No description provided for @invalidBackup.
  ///
  /// In ar, this message translates to:
  /// **'ملف النسخة الاحتياطية غير صالح.'**
  String get invalidBackup;

  /// No description provided for @searchLibrary.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في الفيديوهات والترجمات'**
  String get searchLibrary;

  /// No description provided for @continueWatching.
  ///
  /// In ar, this message translates to:
  /// **'أكمل المشاهدة'**
  String get continueWatching;

  /// No description provided for @inSubtitles.
  ///
  /// In ar, this message translates to:
  /// **'في الترجمات'**
  String get inSubtitles;

  /// No description provided for @sleepTimer.
  ///
  /// In ar, this message translates to:
  /// **'مؤقت النوم'**
  String get sleepTimer;

  /// No description provided for @sleepOff.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف المؤقت'**
  String get sleepOff;

  /// No description provided for @sleepMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} دقيقة'**
  String sleepMinutes(int minutes);

  /// No description provided for @watchWhileTranslating.
  ///
  /// In ar, this message translates to:
  /// **'شاهد الآن أثناء الترجمة'**
  String get watchWhileTranslating;

  /// No description provided for @detectLanguage.
  ///
  /// In ar, this message translates to:
  /// **'كشف اللغة تلقائيًا'**
  String get detectLanguage;

  /// No description provided for @languageDetected.
  ///
  /// In ar, this message translates to:
  /// **'تم كشف اللغة: {name}'**
  String languageDetected(String name);

  /// No description provided for @errLanguageUnsupported.
  ///
  /// In ar, this message translates to:
  /// **'اللغة المكتشفة غير مدعومة للترجمة حاليًا.'**
  String get errLanguageUnsupported;

  /// No description provided for @detectNeedsModel.
  ///
  /// In ar, this message translates to:
  /// **'حمّل نموذج الكلام متعدد اللغات أولاً لكشف اللغة.'**
  String get detectNeedsModel;

  /// No description provided for @transcriptTitle.
  ///
  /// In ar, this message translates to:
  /// **'النص الكامل'**
  String get transcriptTitle;

  /// No description provided for @copyAll.
  ///
  /// In ar, this message translates to:
  /// **'نسخ الكل'**
  String get copyAll;

  /// No description provided for @shareText.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة كنص'**
  String get shareText;

  /// No description provided for @copied.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ'**
  String get copied;

  /// No description provided for @errInvalidLink.
  ///
  /// In ar, this message translates to:
  /// **'هذا لا يبدو عنوان ويب. الصق الرابط كاملًا، مثل https://…'**
  String get errInvalidLink;

  /// No description provided for @errNoVideo.
  ///
  /// In ar, this message translates to:
  /// **'لم نجد فيديو قابلًا للتحميل في هذه الصفحة. افتح الصفحة وشغّل الفيديو ثم اختره من قائمة المكتشَف.'**
  String get errNoVideo;

  /// No description provided for @errSiteRefused.
  ///
  /// In ar, this message translates to:
  /// **'رفض الموقع التحميل (قد يحتاج تسجيل دخول أو يمنع التحميل).'**
  String get errSiteRefused;

  /// No description provided for @errLink.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل هذا الرابط.'**
  String get errLink;

  /// No description provided for @browserHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب أو الصق رابطًا'**
  String get browserHint;

  /// No description provided for @browserStart.
  ///
  /// In ar, this message translates to:
  /// **'افتح موقعًا وشغّل الفيديو، وسيكتشفه التطبيق لتحمّل واحدًا أو أكثر.'**
  String get browserStart;

  /// No description provided for @browserDetected.
  ///
  /// In ar, this message translates to:
  /// **'الفيديوهات المكتشفة'**
  String get browserDetected;

  /// No description provided for @browserNone.
  ///
  /// In ar, this message translates to:
  /// **'لم يُكتشف فيديو بعد. شغّل الفيديو في الصفحة ثم افتح هذه القائمة مرة أخرى.'**
  String get browserNone;

  /// No description provided for @browserDownloadPage.
  ///
  /// In ar, this message translates to:
  /// **'تحميل فيديو هذه الصفحة'**
  String get browserDownloadPage;

  /// No description provided for @browserDownloadSelected.
  ///
  /// In ar, this message translates to:
  /// **'تحميل المحدد ({count})'**
  String browserDownloadSelected(int count);

  /// No description provided for @browserAdded.
  ///
  /// In ar, this message translates to:
  /// **'أُضيف {count} إلى التحميلات'**
  String browserAdded(int count);

  /// No description provided for @downloadsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التحميلات'**
  String get downloadsTitle;

  /// No description provided for @downloadsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تحميلات بعد'**
  String get downloadsEmpty;

  /// No description provided for @downloadWaiting.
  ///
  /// In ar, this message translates to:
  /// **'في الانتظار'**
  String get downloadWaiting;

  /// No description provided for @downloadOpen.
  ///
  /// In ar, this message translates to:
  /// **'فتح'**
  String get downloadOpen;

  /// No description provided for @downloadRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get downloadRetry;

  /// No description provided for @downloadClearDone.
  ///
  /// In ar, this message translates to:
  /// **'مسح المنتهية'**
  String get downloadClearDone;

  /// No description provided for @downloadDone.
  ///
  /// In ar, this message translates to:
  /// **'أُضيف إلى مكتبتك'**
  String get downloadDone;

  /// No description provided for @downloadFailedReason.
  ///
  /// In ar, this message translates to:
  /// **'السبب: {reason}'**
  String downloadFailedReason(String reason);

  /// No description provided for @autoSaveTitle.
  ///
  /// In ar, this message translates to:
  /// **'احفظ التحميلات في المعرض أيضًا'**
  String get autoSaveTitle;

  /// No description provided for @autoSaveBody.
  ///
  /// In ar, this message translates to:
  /// **'يحتفظ بنسخة في Movies/Tarjuman لتراها التطبيقات الأخرى. يستهلك مساحة إضافية.'**
  String get autoSaveBody;

  /// No description provided for @saveToDevice.
  ///
  /// In ar, this message translates to:
  /// **'حفظ على الجهاز'**
  String get saveToDevice;

  /// No description provided for @shareFile.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة الملف'**
  String get shareFile;

  /// No description provided for @videoActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات الفيديو'**
  String get videoActions;

  /// No description provided for @savedToDevice.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ في Movies/Tarjuman'**
  String get savedToDevice;

  /// No description provided for @sharedInstead.
  ///
  /// In ar, this message translates to:
  /// **'اختر مكان حفظ الملف'**
  String get sharedInstead;

  /// No description provided for @downloadSaved.
  ///
  /// In ar, this message translates to:
  /// **'محفوظ في المعرض أيضًا'**
  String get downloadSaved;

  /// No description provided for @pasteLink.
  ///
  /// In ar, this message translates to:
  /// **'لصق الرابط'**
  String get pasteLink;

  /// No description provided for @downloadingNotificationTitle.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحميل الفيديوهات'**
  String get downloadingNotificationTitle;

  /// No description provided for @downloadingCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{تحميل واحد قيد التنفيذ} other{{count} تحميلات قيد التنفيذ}}'**
  String downloadingCount(int count);

  /// No description provided for @downloadFinishedTitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتمل التحميل'**
  String get downloadFinishedTitle;

  /// No description provided for @downloadFailedTitle.
  ///
  /// In ar, this message translates to:
  /// **'فشل التحميل'**
  String get downloadFailedTitle;

  /// No description provided for @videoGlossaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'قاموس هذا الفيديو'**
  String get videoGlossaryTitle;

  /// No description provided for @videoGlossaryHint.
  ///
  /// In ar, this message translates to:
  /// **'هذه المصطلحات تخص هذا الفيديو فقط وتتقدّم على القاموس العام. تؤثر على الترجمات الجديدة (أعد الترجمة لتطبيقها على السطور الحالية).'**
  String get videoGlossaryHint;

  /// No description provided for @needsReview.
  ///
  /// In ar, this message translates to:
  /// **'يحتاج مراجعة ({count})'**
  String needsReview(int count);

  /// No description provided for @speakerLabel.
  ///
  /// In ar, this message translates to:
  /// **'المتحدث'**
  String get speakerLabel;

  /// No description provided for @issueUntranslated.
  ///
  /// In ar, this message translates to:
  /// **'لم تُترجم'**
  String get issueUntranslated;

  /// No description provided for @issueLatin.
  ///
  /// In ar, this message translates to:
  /// **'أغلبها حروف لاتينية'**
  String get issueLatin;

  /// No description provided for @issueTooShort.
  ///
  /// In ar, this message translates to:
  /// **'أقصر بكثير من الأصل'**
  String get issueTooShort;

  /// No description provided for @issueTooLong.
  ///
  /// In ar, this message translates to:
  /// **'أطول بكثير من الأصل'**
  String get issueTooLong;

  /// No description provided for @issueFast.
  ///
  /// In ar, this message translates to:
  /// **'أسرع من أن تُقرأ'**
  String get issueFast;

  /// No description provided for @issueRepeated.
  ///
  /// In ar, this message translates to:
  /// **'مثل السطر السابق'**
  String get issueRepeated;
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
