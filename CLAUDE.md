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

## 9. Current status (v1.2.0+3)

Built (all phases have code; ASR/translation quality and speed are **NOT yet verified on real devices**):
- Foundation: design system, library (drift), player (`video_player`), SRT/VTT import, subtitle style sheet, l10n AR/EN.
- Processing (phases 2–3): `AudioExtractor` (FFmpegKit **audio** build, LGPL — never use the full-GPL variant),
  `SpeechRecognizer` (whisper.cpp via `whisper_cpp_flutter_plus`), `TextTranslator` (ML Kit), pipeline in 3-minute
  chunks, cues persisted per chunk, resume after kill (restarts from the last chunk boundary), cancel.
- Model manager: Whisper `base.en` / `tiny.en` (checksum-pinned catalog) + ML Kit en/ar.
- Live (phase 4): `LiveSubtitleSession` translates the 30 s window under the playhead + the next; seek re-targets.
  Live results are **not persisted** (windows may leave gaps; Prepare mode's resume logic assumes contiguous cues).
- Online (phase 5): OpenAI-compatible ASR + chat-translation adapters, behind consent + API key in the keystore.
  Unverified without a key. Direct-link video URLs are NOT implemented yet (local files only).
- Any-format input: picker uses `FileType.any`; import validates by content (FFprobe must read a duration), not by
  extension. Playback = media_kit; audio extraction = FFmpegKit audio build (demuxers verified in the binary: avi, flv,
  mkv/webm, mov/mp4/3gp, wmv/asf, ts, mpeg, ogg, wav, mp3, flac, amr, ac3, dts, rm; decoders: aac, ac3, mp3, vorbis,
  opus, flac, wma, alac, amr, dca, pcm). Exotic video-only/DRM files are still rejected.
- Settings: theme, online consent, API key. Release: Android signing, icon, fonts.
- Emulator note: the Pixel_9 AVD has 2 GB RAM and the OS kills the debug app during the file picker. Test on a real
  device (or raise `hw.ramSize` to 4096 in `~/.android/avd/Pixel_9.avd/config.ini`).

Known gaps / next:
- Device spike (RTF, RAM, battery) for tiny.en vs base.en; tune chunk size and `CueSegmenter` on real videos.
- Screen is kept awake during processing via `wakelock_plus`; if the app is still killed, resume covers it.
- Chunk boundaries can cut a sentence in two; consider overlap or silence-aware cuts after benchmarking.
- Subtitle editor screen, direct-link sources, iOS build/signing (needs Apple account).
Release how-to: `docs/RELEASE.md`.
