# Architecture rules

## Layers (Clean Architecture, feature-first)

```
presentation  ──►  domain  ◄──  data
 (Cubit, UI)      (pure Dart)   (adapters, DB, packages)
```

- `domain/` — entities (immutable, `freezed`), repository **interfaces**, use cases. No `flutter`, no
  packages except `meta`/`freezed_annotation`. Fully unit-testable.
- `data/` — implements domain interfaces. Only layer that knows `drift`, `media_kit`, whisper, ML Kit, dio.
  Maps DTO ⇄ entity in mappers (`toEntity()` / `toDto()`), never leaks DTOs upward.
- `presentation/` — Cubit + immutable state + widgets. Talks to use cases only (never repositories directly,
  never data sources).
- Cross-feature access goes through a domain interface or a shared `core/` type, never by importing another
  feature's `data/` or `presentation/`.

## Ports (the pluggable seams — define in domain, implement in data)

```dart
abstract interface class AudioExtractor {
  Future<Result<ExtractedAudio>> extract(MediaSource source, {CancelToken? cancel});
}
abstract interface class SpeechRecognizer {
  Future<Result<List<TranscriptSegment>>> transcribeFile(AudioFile audio, {CancelToken? cancel});
  Stream<RecognitionEvent> transcribeStream(Stream<AudioChunk> chunks); // Live mode (phase 4)
  Future<void> dispose();
}
abstract interface class TextTranslator {
  Future<Result<String>> translate(String text, {required Language from, required Language to});
  Future<Result<List<String>>> translateBatch(List<String> texts, {required Language from, required Language to});
}
abstract interface class PlayerEngine { /* lives in core/platform/media because it exposes a Widget surface */ }
```

- Offline vs Online = **different implementations of the same port**, chosen by a factory driven by user
  settings. UI and data model are identical for both. Never branch on "online" inside a Cubit.
- Adding a new ASR/translator must require **zero** changes in `presentation/` and use cases.

## Processing pipeline

- A `ProcessingJob` (persisted in drift) moves through stages: `queued → extractingAudio → transcribing →
  translating → ready | failed | cancelled`. Each stage writes a checkpoint so the job resumes after a kill.
- Orchestrated by `RunProcessingPipeline` use case (Template Method over stages; each stage = Strategy).
- Heavy work runs off the UI isolate (`Isolate.run` / platform channel threads). Load the ASR model once per
  job, reuse the translator across segments, release both at the end.
- Progress is a `Stream<JobProgress>` (stage, fraction, ETA); the Cubit maps it to UI state.

## Subtitle timeline

- `SubtitleCue(start: Duration, end: Duration, text, {original, status})`, `status ∈ {partial, committed, edited}`.
- `SubtitleTimeline` owns cues sorted by `start`; active cue lookup is **binary search** (or a moving index
  reset on seek). No linear scans in the position listener.
- Live mode: partial cues may be replaced in place; once committed they are immutable until the user edits.
- Time always comes from the audio position inside the media, never from wall-clock or job completion time.

## State management

- One Cubit per screen/feature concern; state = `freezed` union or a single immutable class with status enum.
  No `bool isLoading, bool hasError` combos — model impossible states out.
- Cubits never hold `BuildContext`, never navigate (emit a one-shot effect via `BlocListener` + state field or
  a `Stream<Effect>`), never call packages directly.
- Streams are subscribed in the Cubit and cancelled in `close()`.

## Dependency injection

- `get_it`, manual composition root in `app/di/injection.dart`. Register interfaces, not implementations.
  Use `instanceName: 'offline'` / `'online'` for variant adapters. Per-screen objects (player cubit + engine) via factory functions.

## Error handling

- `sealed class Failure` in `core/error` (`StorageFailure`, `ModelMissingFailure`, `UnsupportedMediaFailure`,
  `NetworkFailure`, `CancelledFailure`, `UnknownFailure`...). Adapters catch package exceptions and convert.
- UI maps `Failure → localized, actionable message` in one place (`FailureMessageMapper`).

## Persistence

- drift tables: `videos`, `transcripts`, `cues`, `jobs`, `model_assets`. Direct, versioned schema migrations.
- Files (audio temp, models) live in the app support dir; temp audio deleted when the job completes.
- Never keep a whole video/audio in memory; stream or chunk.

## Anti-patterns (reject in review)

God cubits/services · `Utils` dumping grounds · singletons reached via `Foo.instance` · `dynamic` ·
package types in domain · business rules in widgets or mappers · `if (Platform.isAndroid)` outside `core/platform` ·
catch-all `catch (e) {}`.
