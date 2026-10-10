import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarjuman/core/design_system/tokens/app_theme.dart';
import 'package:tarjuman/core/platform/background/background_processing.dart';
import 'package:tarjuman/core/platform/device/brightness_control.dart';
import 'package:tarjuman/core/platform/media/player_engine.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/library/domain/usecases/delete_video.dart';
import 'package:tarjuman/features/library/domain/usecases/import_from_url.dart';
import 'package:tarjuman/features/library/domain/usecases/import_video.dart';
import 'package:tarjuman/features/library/domain/usecases/toggle_favorite.dart';
import 'package:tarjuman/features/library/domain/usecases/watch_library.dart';
import 'package:tarjuman/features/library/presentation/cubit/library_cubit.dart';
import 'package:tarjuman/features/library/presentation/pages/library_page.dart';
import 'package:tarjuman/features/model_manager/domain/entities/model_info.dart';
import 'package:tarjuman/features/model_manager/domain/repositories/model_repository.dart';
import 'package:tarjuman/features/model_manager/presentation/cubit/models_cubit.dart';
import 'package:tarjuman/features/model_manager/presentation/pages/models_page.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_style.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';
import 'package:tarjuman/features/player/domain/repositories/subtitle_repository.dart';
import 'package:tarjuman/features/player/domain/usecases/attach_subtitles.dart';
import 'package:tarjuman/features/player/domain/usecases/load_player_data.dart';
import 'package:tarjuman/features/player/presentation/cubit/player_cubit.dart';
import 'package:tarjuman/features/player/presentation/pages/player_page.dart';
import 'package:tarjuman/features/player/presentation/widgets/subtitle_style_sheet.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/ports/engine_provider.dart';
import 'package:tarjuman/features/processing/domain/usecases/live_subtitle_session.dart';
import 'package:tarjuman/features/processing/domain/usecases/run_processing_pipeline.dart';
import 'package:tarjuman/features/processing/presentation/cubit/processing_cubit.dart';
import 'package:tarjuman/features/processing/presentation/cubit/setup_cubit.dart';
import 'package:tarjuman/features/processing/presentation/pages/processing_page.dart';
import 'package:tarjuman/features/processing/presentation/pages/setup_page.dart';
import 'package:tarjuman/features/subtitle_editor/domain/usecases/edit_cue_text.dart';
import 'package:tarjuman/features/subtitle_editor/domain/usecases/export_subtitles.dart';
import 'package:tarjuman/features/subtitle_editor/presentation/cubit/editor_cubit.dart';
import 'package:tarjuman/features/subtitle_editor/presentation/pages/editor_page.dart';
import 'package:tarjuman/features/vocabulary/domain/ports/word_translator.dart';
import 'package:tarjuman/features/vocabulary/domain/repositories/vocabulary_repository.dart';
import 'package:tarjuman/features/vocabulary/presentation/cubit/study_cubit.dart';
import 'package:tarjuman/features/vocabulary/presentation/widgets/study_sheet.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

import 'scene.dart';

// ---- fakes / mocks ---------------------------------------------------------
class _Settings implements SettingsStore {
  @override
  SubtitleStyle readSubtitleStyle() => const SubtitleStyle(showOriginal: true);
  @override
  Future<void> writeSubtitleStyle(SubtitleStyle style) async {}
  @override
  ThemeMode readThemeMode() => ThemeMode.dark;
  @override
  Future<void> writeThemeMode(ThemeMode mode) async {}
  @override
  bool readOnlineConsent() => true;
  @override
  Future<void> writeOnlineConsent({required bool value}) async {}
  @override
  Duration readSubtitleOffset(String videoId) => Duration.zero;
  @override
  Future<void> writeSubtitleOffset(String videoId, Duration offset) async {}
  @override
  bool readOnboardingDone() => true;
  @override
  Future<void> writeOnboardingDone() async {}
  @override
  String readSourceLanguage() => 'en';
  @override
  Future<void> writeSourceLanguage(String code) async {}
}

class _Secrets implements SecretStore {
  @override
  Future<String?> readApiKey() async => 'sk-demo';
  @override
  Future<void> writeApiKey(String? key) async {}
}

class _MWatch extends Mock implements WatchLibrary {}

class _MImport extends Mock implements ImportVideo {}

class _MImportUrl extends Mock implements ImportFromUrl {}

class _MDelete extends Mock implements DeleteVideo {}

class _MFavorite extends Mock implements ToggleFavorite {}

class _MVideos extends Mock implements VideoRepository {}

class _MSubs extends Mock implements SubtitleRepository {}

class _MLoad extends Mock implements LoadPlayerData {}

class _MAttach extends Mock implements AttachSubtitles {}

class _MEngines extends Mock implements EngineProvider {}

class _MPipeline extends Mock implements RunProcessingPipeline {}

class _MModels extends Mock implements ModelRepository {}

class _MExport extends Mock implements ExportSubtitles {}

class _MLive extends Mock implements LiveSubtitleSession {}

class _NoBackground implements BackgroundProcessing {
  @override
  Future<void> start({required String title, required String text}) async {}
  @override
  Future<void> update(String text) async {}
  @override
  Future<void> stop() async {}
}

class _Brightness implements BrightnessControl {
  @override
  Future<double> current() async => .5;
  @override
  Future<void> set(double value) async {}
  @override
  Future<void> reset() async {}
}

class _PlayerC extends PlayerCubit {
  _PlayerC(PlayerState s)
    : super(
        videoId: 'v',
        videos: _MVideos(),
        engine: SceneEngine(),
        brightness: _Brightness(),
        load: _MLoad(),
        attach: _MAttach(),
        settings: _Settings(),
        engines: _MEngines(),
        liveFactory: _MLive.new,
      ) {
    emit(s);
  }
}

class _ProcC extends ProcessingCubit {
  _ProcC(ProcessingState s)
    : super(
        videoId: 'v',
        kind: EngineKind.offline,
        pipeline: _MPipeline(),
        background: _NoBackground(),
        notificationTitle: '',
        notificationText: (p) => '$p%',
      ) {
    emit(s);
  }
}

class _SetupC extends SetupCubit {
  _SetupC(SetupState s)
    : super(_MVideos(), _MModels(), _Settings(), _Secrets()) {
    emit(s);
  }
}

class _ModelsC extends ModelsCubit {
  _ModelsC(ModelsState s) : super(_MModels()) {
    emit(s);
  }
}

class _EditorC extends EditorCubit {
  _EditorC(EditorState s)
    : super(
        videoId: 'v',
        subtitles: _MSubs(),
        edit: EditCueText(_MSubs()),
        export: _MExport(),
      ) {
    emit(s);
  }
}

class _StudyC extends StudyCubit {
  _StudyC() : super(_MWordTranslator(), _MVocab()) {
    emit(const StudyState(word: 'learn', translation: 'يتعلّم', saved: true));
  }
}

class _MWordTranslator extends Mock implements WordTranslator {}

class _MVocab extends Mock implements VocabularyRepository {}

// ---- sample data -----------------------------------------------------------
final _now = DateTime(2026, 10, 9);

Video _video(String title, VideoStatus s, SubtitleOrigin o) => Video(
  id: title,
  title: title,
  path: '/$title',
  createdAt: _now,
  status: s,
  origin: o,
);

final sampleVideos = [
  _video(
    'How AI Learns — Lecture 3.mp4',
    VideoStatus.ready,
    SubtitleOrigin.offline,
  ),
  _video(
    'Design Systems in Practice.mkv',
    VideoStatus.processing,
    SubtitleOrigin.none,
  ),
  _video(
    'Startup Founders Panel.mp4',
    VideoStatus.ready,
    SubtitleOrigin.offline,
  ),
  _video(
    'Intro to Flutter Animations.avi',
    VideoStatus.ready,
    SubtitleOrigin.online,
  ),
  _video(
    'The Future of Medicine.mov',
    VideoStatus.imported,
    SubtitleOrigin.none,
  ),
];

SubtitleCue _cue(
  int s,
  int e,
  String ar,
  String en, [
  CueStatus st = CueStatus.committed,
]) => SubtitleCue(
  start: Duration(seconds: s),
  end: Duration(seconds: e),
  text: ar,
  original: en,
  status: st,
);

final sampleCues = [
  _cue(248, 252, 'أهلاً بعودتكم جميعًا.', 'Welcome back, everyone.'),
  _cue(
    252,
    256,
    'الذكاء الاصطناعي سيغيّر طريقة تعلّمنا خلال العقد القادم.',
    'AI will change how we learn in the next decade.',
  ),
  _cue(
    256,
    259,
    'دعني أريك كيف يبدو ذلك.',
    'Let me show you what that looks like.',
    CueStatus.edited,
  ),
  _cue(259, 262, 'أولاً، مثال سريع.', 'First, a quick example.'),
  _cue(
    262,
    266,
    'تخيّل فصلاً دراسيًا لطالب واحد.',
    'Imagine a classroom of one.',
  ),
  _cue(
    266,
    270,
    'معلّم يعرف مستواك تمامًا.',
    'A teacher who knows exactly where you are.',
  ),
];

// ---- builders ---------------------------------------------------------------
Widget _app(Locale locale, Widget home) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.dark,
  darkTheme: AppTheme.dark,
  themeMode: ThemeMode.dark,
  locale: locale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      padding: const EdgeInsets.only(top: 30, bottom: 18),
      viewPadding: const EdgeInsets.only(top: 30, bottom: 18),
    ),
    child: child!,
  ),
  home: home,
);

class StatusBarMock extends StatelessWidget {
  const StatusBarMock({super.key});

  @override
  Widget build(BuildContext context) => const Directionality(
    textDirection: TextDirection.ltr,
    child: Padding(
      padding: EdgeInsets.fromLTRB(22, 8, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'IBMPlexSansArabic',
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.signal_cellular_alt_rounded,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 4),
              Icon(Icons.wifi_rounded, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Icon(Icons.battery_full_rounded, color: Colors.white, size: 16),
            ],
          ),
        ],
      ),
    ),
  );
}

PlayerState _playerState({bool controls = true}) => PlayerState(
  status: PlayerStatus.ready,
  video: sampleVideos.first,
  timeline: SubtitleTimeline(sampleCues),
  snapshot: const PlaybackSnapshot(
    position: Duration(minutes: 4, seconds: 12),
    duration: Duration(minutes: 42, seconds: 10),
    isPlaying: true,
    isReady: true,
  ),
  style: const SubtitleStyle(showOriginal: true),
  activeText: sampleCues[1].text,
  activeOriginal: sampleCues[1].original,
  controlsVisible: controls,
);

/// Every store screen, keyed by file name. `locale` switches the real UI language.
Map<String, Widget Function(Locale)> storeScreens() => {
  '01-library': (l) {
    final watch = _MWatch();
    when(watch.call).thenAnswer((_) => Stream.value(sampleVideos));
    final cubit = LibraryCubit(
      watch,
      _MImport(),
      _MImportUrl(),
      _MDelete(),
      _MFavorite(),
    );
    return _app(
      l,
      BlocProvider.value(value: cubit, child: const LibraryView()),
    );
  },
  '02-player': (l) => _app(
    l,
    BlocProvider<PlayerCubit>.value(
      value: _PlayerC(_playerState()),
      child: const PlayerView(),
    ),
  ),
  '03-processing': (l) => _app(
    l,
    BlocProvider<ProcessingCubit>.value(
      value: _ProcC(
        const ProcessingState(
          stage: ProcessingStage.transcribing,
          fraction: .62,
          remaining: Duration(minutes: 3),
        ),
      ),
      child: const ProcessingView(videoId: 'v'),
    ),
  ),
  '04-setup': (l) => _app(
    l,
    BlocProvider<SetupCubit>.value(
      value: _SetupC(
        SetupState(
          video: sampleVideos[3],
          offlineReady: true,
          onlineReady: true,
          loading: false,
        ),
      ),
      child: const SetupView(videoId: 'v'),
    ),
  ),
  '05-models': (l) => _app(
    l,
    BlocProvider<ModelsCubit>.value(
      value: _ModelsC(
        const ModelsState(
          loading: false,
          progress: {'base.en': .48},
          models: [
            ModelInfo(
              id: 'base.en',
              kind: ModelKind.speech,
              name: 'Base · English',
              sizeBytes: 148 * 1024 * 1024,
              installed: false,
            ),
            ModelInfo(
              id: 'tiny.en',
              kind: ModelKind.speech,
              name: 'Tiny · English',
              sizeBytes: 78 * 1024 * 1024,
              installed: true,
            ),
            ModelInfo(
              id: 'mlkit.en',
              kind: ModelKind.translation,
              name: 'English',
              sizeBytes: 30 * 1024 * 1024,
              installed: true,
            ),
            ModelInfo(
              id: 'mlkit.ar',
              kind: ModelKind.translation,
              name: 'Arabic',
              sizeBytes: 30 * 1024 * 1024,
              installed: true,
            ),
          ],
        ),
      ),
      child: const ModelsView(),
    ),
  ),
  '06-style': (l) {
    final cubit = _PlayerC(
      _playerState(controls: false).copyWith(
        style: const SubtitleStyle(
          showOriginal: true,
          position: SubtitlePosition.top,
        ),
      ),
    );
    return _app(
      l,
      BlocProvider<PlayerCubit>.value(
        value: cubit,
        child: Builder(
          builder: (context) => Stack(
            children: [
              const PlayerView(),
              const Positioned.fill(
                child: ColoredBox(color: Color(0x8C05070B)),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: SubtitleStyleSheet(
                    style: const SubtitleStyle(showOriginal: true),
                    onChanged: (_) {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
  '07-editor': (l) => _app(
    l,
    BlocProvider<EditorCubit>.value(
      value: _EditorC(EditorState(cues: sampleCues, loading: false)),
      child: const EditorView(videoId: 'v'),
    ),
  ),
  '08-study': (l) => _app(
    l,
    MultiBlocProvider(
      providers: [
        BlocProvider<PlayerCubit>.value(
          value: _PlayerC(_playerState(controls: false)),
        ),
        BlocProvider<StudyCubit>.value(value: _StudyC()),
      ],
      child: Builder(
        builder: (context) => Stack(
          children: [
            const PlayerView(),
            const Positioned.fill(child: ColoredBox(color: Color(0x8C05070B))),
            Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: const StudySheet(),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
};
