# Tarjuman (ترجمان) — Project Context for Claude Code

> "Tarjuman / ترجمان" is a **working name**. Renaming = change `pubspec.yaml`, the package id, and
> `docs/BRAND_GUIDELINES.md` §1. Nothing else hard-codes it (use `AppConfig.appName`).

Read this file fully, then the rules in `.claude/rules/` (they are loaded as the source of truth for
style, architecture, testing, UI and workflow). Brand/visual source of truth: `docs/BRAND_GUIDELINES.md`
and the interactive board `docs/design/brand-and-screens.html`.

---

## 1. What this is

A Flutter app (Android + iOS) that plays a video and shows **Arabic subtitles generated from the
English speech**, synced on the video itself. **Offline-first**, with an optional online path.

Pipeline (four stages, each behind an interface — see `.claude/rules/architecture.md`):

1. **Playback** — local file or direct video URL.
2. **ASR** — extract audio → English text + timestamps (`whisper.cpp` first, `sherpa-onnx` as the alternative).
3. **Translation** — EN → AR (Google ML Kit on-device first; cloud as optional adapter).
4. **Subtitle timeline** — Arabic cues bound to the *audio* time of the video, rendered over the player.

Two processing modes, built in this order:

| Mode | Behaviour | Phase |
|---|---|---|
| **Pre-process** | Analyse whole file, produce SRT-like timeline, then play | 1–3 (MVP) |
| **Live** | Short audio chunks while playing; partial cues revised, then committed | 4 |
| **Online** | Cloud ASR/translation adapters, same UI + data model | 5 |

Decisions already made by the owner: **both modes**, **Android + iPhone**, **local files + direct links**.
Not supported (do not build): page URLs of video platforms (YouTube etc.), DRM content, mic capture as
audio source.

## 2. Roadmap (MVP = phases 1–3)

1. **Foundation** — player, SRT/WebVTT import, subtitle styling, settings persistence.
2. **ASR** — audio extraction + local transcription, persisted.
3. **Offline translation** — ML Kit model manager, segment translation, editable cues.
4. **Live** — chunked pipeline, partial → committed cues, seek handling.
5. **Online** — cloud adapters, direct-link/stream sources.

Each phase has a measurable exit criterion (see the owner's plan): never mark a phase done without
running it on **real Android + iPhone devices in release mode**.

## 3. Tech stack (decided — don't swap without asking)

| Concern | Choice |
|---|---|
| Language | Dart 3 (sealed classes, records, patterns), null-safety, strict analysis |
| State | `flutter_bloc` (**Cubit by default**, Bloc only for event-heavy flows) |
| DI | `get_it` with a manual composition root in `lib/app/di/injection.dart` (no `injectable`: same analyzer conflict) |
| Navigation | `go_router` |
| Models / state | plain immutable classes + `equatable` (no `freezed`: its analyzer range conflicts with `drift_dev` on the current Dart SDK) |
| Local DB | `drift` pinned to 2.31.0 / `drift_dev` 2.31.0 / `drift_flutter` 0.2.7 (newer ones need a newer Dart SDK) — videos, cues, later jobs |
| Prefs | `shared_preferences` behind a `SettingsStore` port |
| Player | `media_kit` (libmpv) behind `PlayerEngine` (`core/platform/media`) — plays practically any container/codec |
| Audio extraction | FFmpeg (community fork — **spike & license-check before adopting**) behind `AudioExtractor` |
| ASR | `whisper.cpp` binding behind `SpeechRecognizer` |
| Translation | `google_mlkit_translation` behind `TextTranslator` |
| Lints | `very_good_analysis` + project overrides |
| Tests | `flutter_test`, `bloc_test`, `mocktail` |

Never import a third-party package outside its `data/` adapter (or `core/platform/`). If you find
`package:media_kit` in `presentation/` or `domain/`, that is a bug.

## 4. Folder layout

```
lib/
  main.dart / bootstrap.dart
  app/                    # App widget, router, theme wiring, DI composition root
  core/
    design_system/        # tokens, theme, atoms/molecules (THE only place with raw colors/sizes)
    error/                # Failure hierarchy
    result/               # Result<T> sealed type
    platform/             # thin wrappers: permissions, storage paths, connectivity
    utils/ l10n/
  features/<feature>/
    domain/               # entities, repository interfaces, use cases (pure Dart, no Flutter)
    data/                 # datasources, DTO/models, repository impls, adapters to packages
    presentation/         # cubit/state, pages, widgets
test/                     # mirrors lib/
docs/
```

Features: `library`, `video_import`, `processing`, `player`, `subtitle_editor`, `model_manager`, `settings`.

## 5. Non-negotiables (details in `.claude/rules/`)

- **Dependency rule:** `presentation → domain ← data`. `domain` imports nothing from Flutter or packages.
- **SOLID, small units:** one use case = one `call()`; files < ~250 lines; widgets < ~120 lines per `build`.
- **No logic in widgets.** Widgets render state and forward intents to a Cubit.
- **No raw `Color(0x…)`, `TextStyle(...)`, magic `EdgeInsets` numbers** outside `core/design_system`.
- **RTL-first:** use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start/end`, never `left/right`.
- **Errors are values:** repositories/use cases return `Result<T>`; no thrown exceptions crossing a layer.
- **Subtitle timing is audio time**, never "when the translation finished".
- **Every long task is cancellable, resumable, and persists progress** (app can be killed mid-job).
- **Release-mode device testing** before closing any ASR/translation/player task.
- **Licenses:** record every model/package license in `docs/LICENSES.md` before shipping (e.g. NLLB
  3.3B is CC-BY-NC → not usable commercially).
- **Privacy:** audio leaves the device only in Online mode, with explicit consent copy in the UI.

## 6. How to work with the owner

- Owner (Mohammed, MegTech) is a senior full-stack dev; skip basic Flutter/Dart explanations.
- Replies in Egyptian Arabic are fine; code, identifiers, commits and docs in English.
- **Do not commit or push unless asked.** Report what changed and offer.
- Keep sessions cost-light: one cheap verification after a fix is enough; don't loop on rebuild/screenshot.
- Before adding a dependency: state why, license, maintenance status, and the adapter it will live behind.
- When a decision is open (see §7), propose a recommendation instead of a survey.

## 7. Open decisions / spikes

- [ ] Whisper binding: pick between candidates after a release-mode benchmark (tiny/base/small) on one
      mid-range Android + one iPhone — measure RTF (real-time factor), RAM peak, battery.
- [ ] FFmpeg fork vs. platform-native extraction (MediaExtractor / AVAssetReader) for audio → 16 kHz mono WAV.
- [ ] Final product name + package id.
- [ ] Monetisation (paid extra models / advanced features; core offline flow stays free).

## 8. Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift
flutter gen-l10n
flutter analyze
flutter test
flutter run --release            # for any perf/ASR work
```

## 9. Current status (v1.8.0+11, package `com.megtech.tarjuman`)

Built (ASR/translation quality and speed are **NOT yet verified end-to-end on a real device** — the emulator has 2 GB RAM and kills the app):
- Foundation: design system (tokens + components incl. CueTile, StageStepper, SubtitleView), library (drift v2), player (`media_kit`),
  SRT/VTT import, subtitle style sheet (incl. bilingual EN-over-AR), resume-from-last-position, l10n AR/EN.
- Any-format input: picker `FileType.any`, validated by content (FFprobe duration) not extension; direct-link import
  (https; plain http is blocked by Android cleartext policy). FFmpeg audio build (LGPL) verified in-binary for avi/flv/mkv/mov/wmv/ts/ogg/wav/mp3/flac/amr/ac3/dts.
- Processing: 3-minute chunks, cues persisted per chunk, resume after kill, cancel; Whisper (whisper.cpp) + ML Kit; wakelock during jobs.
- Live mode: translates the 30 s window under the playhead + next; not persisted.
- Subtitle editor: search, edit a line, tap-to-jump, export SRT (optionally with English) via share sheet.
- Online: consent + per-provider keys in keystore. Providers (`OnlineProvider` enum, one place to fix model names/URLs): speech = OpenAI, Groq (free tier), Deepgram; translation = OpenAI, Groq, Gemini, OpenRouter (`:free` models), DeepL (`:fx` keys → free host), MyMemory (no key, tiny quota). Adapters in `features/processing/data/online/`; `OnlineEngines` builds them from `OnlineConfig`; HTTP 401/403 → `OnlineNotConfiguredFailure`, 402/429/456 → `RateLimitedFailure`. Model names are user-overridable in Settings. Adapter logic is unit-tested with MockClient; NOT tested against the real services (no keys yet).
- Model manager (Whisper base.en/tiny.en + ML Kit en/ar), settings (theme, online consent, key, open-source licenses page).
- Store kit in `store/`: Play listing AR/EN, privacy policy HTML, checklist, icon, feature graphics, 8 screenshots per language.
  Regenerate with `STORE_ASSETS=1 flutter test --tags store test/store/store_assets_test.dart --plain-name generate`
  (renders the REAL widgets with sample data, then composes the marketing frames; convert to JPEG with `sips`, see PLAY_STORE_CHECKLIST).
- CI: `.github/workflows/ci.yml` (analyze + test). 34 tests.
- Play gates: 16 KB-aligned native libs (gradle override in `android/build.gradle.kts`), native symbols, in-app privacy link →
  `AppConfig.privacyPolicyUrl` (GitHub Pages repo `mohamedmagdy97/tarjuman-privacy`, content in `store/privacy-site/`).

v1.4–1.5 (analyzer + 48 tests green; the user confirmed the processing flow works after the FFmpeg fix; everything below is not yet device-tested):
- Import: system photo/video picker (`FileType.video`) and any-file picker (`FileType.any`), no storage permission.
- Library: favorites (schema v3), first-run onboarding (`features/onboarding`, models download for en→ar).
- Player: gestures (double-tap ±10 s / play, vertical drag brightness|volume), A-B repeat, embedded audio/subtitle track picker,
  subtitle timing offset (per video), rotate button, secondary actions in a ⋮ menu (fits 360 px width).
- Study mode (`features/vocabulary`): prev/next/repeat sentence, tap a word → ML Kit translation → saved in `Vocabulary` table (schema v4);
  “My words” screen.
- Source languages (`SourceLanguage`: en fr es de it pt tr ru → ar): language chips in setup, Whisper multilingual `tiny`/`base`
  for non-English, ML Kit per-language models, OpenAI adapters take the language.
- Model recommendation from device RAM (`DeviceCapability`, ≥ ~5.5 GB → base else tiny), badge in the Models screen.
- Background processing: `flutter_foreground_task` (dataSync foreground service + progress notification) via `BackgroundProcessing`;
  boot receivers removed. Needs the Play “Foreground service permissions” declaration (see `store/PLAY_STORE_CHECKLIST.md` §4b).
- FFmpeg fix: the async session must be awaited through the complete callback (verified on macOS).
v1.6 (analyzer + 64 tests green; Kotlin compiled via `./gradlew :app:compileReleaseKotlin`; NOT device-tested):
- Open with / Share: `MainActivity.kt` copies the content:// stream to cache and sends {path,name} over the `com.megtech.tarjuman/incoming`
  channel -> `IncomingMediaHandler` -> `ImportSharedMedia` -> /setup/:id. Intent filters in the manifest (video/*, audio/*, VIEW+SEND).
- Quality: adaptive chunk boundaries (3 min + 6 s overlap, next window starts at the end of the last kept cue, resume = end of last cue),
  `CueSegmenter` splits long segments / drops loops and artefacts, Whisper segments with noSpeechProbability >= 0.6 dropped,
  glossary applied before translation (`GlossaryTextTranslator`, experimental), per-line online re-translation in the editor.
  Not possible: sentence context for ML Kit (API has none), word-level timestamps (not wired).
- Vocabulary: spaced repetition (`SpacedRepetition`, SM-2-like; schema v5), review screen, TTS pronunciation (`flutter_tts`), save a whole
  sentence, CSV export + JSON backup/restore.
- Storage screen (videos / models / temp, clear temp, delete video), library-wide subtitle search, Continue watching row (schema v6),
  sleep timer.
v1.7 speed + reading (analyzer + 71 tests green; NOT device-tested, no measured numbers yet — measure RTF on a real phone before tuning):
- Perceived speed: first window is 30 s (`firstChunk`), `ProcessingPartial` event after each saved chunk lets the user tap "Watch now while
  it translates" (`/player/:id?follow=1`, the player polls new cues every 4 s while the video is `processing`).
- Real speed: Silero VAD (`vadModelPath`, auto-downloaded, <1 MB, fallback to no-VAD on failure), 5-bit quantized Whisper models
  (`*-q5_1`, hashes pinned from the same HF revision) are now the recommended ones, translation of chunk N overlaps with recognition
  of chunk N+1 (`ProcessRange.transcribe` / `translate`; next window start comes from the transcript so it is known early),
  ML Kit translates 4 lines concurrently.
- Auto language detection (`DetectLanguage`, multilingual Whisper `detectLanguage`, button in setup), transcript reading screen
  (`/transcript/:id`, copy / share .txt).
v1.8 online providers (analyzer clean, 83 tests; real-API behaviour unverified — Gemini OpenAI-compat endpoint, Deepgram response shape, DeepL AR, OpenRouter free model id).
Deliberately NOT done: burned-in subtitle video export (needs an FFmpeg build with libass + a video encoder → much larger APK),
in-app gallery browser (needs `READ_MEDIA_VIDEO`), sibling-.srt auto-load, PiP/background audio, playlists, iOS.

Known gaps / next:
- Device spike (RTF, RAM, battery) for tiny.en vs base.en; tune chunk size and `CueSegmenter` on real videos; chunk boundaries can split a sentence.
- Background processing as a foreground service/notification; extra source languages; crash reporting (Sentry/Crashlytics); APK size (~76 MB).
- iOS build/signing (needs Apple account); hosting the privacy policy + support email placeholders in `store/`.
Release how-to: `docs/RELEASE.md`. Play launch steps: `store/PLAY_STORE_CHECKLIST.md`.
