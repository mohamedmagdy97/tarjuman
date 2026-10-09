# Testing rules

Unlike earlier projects, this one is **test-covered from day one**.

## What to test
| Layer | Tests | Tools |
|---|---|---|
| domain (use cases, timeline, SRT/VTT parser, segmentation) | unit, exhaustive edge cases | `flutter_test`, `mocktail` |
| data (mappers, repositories, drift DAOs) | unit + in-memory drift | `drift` `NativeDatabase.memory()` |
| presentation (Cubits) | state sequences | `bloc_test` |
| design system | golden tests, light + dark, RTL, 1.0 and 2.0 text scale | `flutter_test` goldens |
| pipeline | integration test with fake `AudioExtractor` / `SpeechRecognizer` / `TextTranslator` | fakes in `test/fakes/` |
| devices | manual release-mode checklist below | real Android + iPhone |

## Rules
- Test behaviour, not implementation. One assertion theme per test; names read as sentences.
- Fakes over mocks for ports used widely (`FakeSpeechRecognizer`); mocks for one-off interactions.
- Mirror `lib/` structure under `test/`. No test touches the network or real model files.
- Timeline/sync logic is the highest risk: property-style tests for seek forward/back, overlapping cues,
  empty gaps, speed changes, partial→committed replacement.
- Bug fix = failing test first.
- CI gate: `flutter analyze` clean, tests green, coverage on `domain/` ≥ 90 %.

## Release-mode device checklist (before closing ASR / translation / live / player work)
- Short + long (>1 h) video, one speaker + several, fast speech, technical terms, accents, music/noise, silent video.
- Mid-range Android + supported iPhone; measure RTF, peak RAM, battery drain.
- Out of storage, connection lost, app killed mid-job → resumes.
- Seek forward/back, speed 0.5–2×, rotate, background/foreground.
- Airplane mode after models are downloaded → full flow still works.
