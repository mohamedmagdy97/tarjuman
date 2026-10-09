# Dart / code style rules

Write code that reads like the surrounding code. Clean, null-safe, modern Dart 3.

## Naming & files
- Files `snake_case.dart`; one public type per file (small private helpers may share). Suffix by role:
  `*_cubit.dart`, `*_state.dart`, `*_page.dart`, `*_repository.dart`, `*_repository_impl.dart`,
  `*_model.dart` (DTO), `*_use_case.dart`.
- Interfaces: `abstract interface class X`; impl: `XImpl` or descriptive (`WhisperSpeechRecognizer`).
- Booleans read as questions (`isReady`, `hasModel`). No abbreviations except well-known (`id`, `url`, `asr`).
- Private by default; export through a feature barrel only what other layers need.

## Language features
- `final` everywhere; `const` constructors and widgets wherever possible.
- Prefer sealed classes + exhaustive `switch` expressions over `if/else` ladders on types or enums.
- Records for small multi-value returns; `equatable` + hand-written `copyWith` for entities/state.
- Named parameters with `required` for >2 args. No positional booleans.
- No `!` on nullable values without a comment-free proof right above it; prefer pattern matching / early return.
- No `dynamic`, no `as` casts across layers, no `late` for things that can be constructor-injected.
- Extensions for tiny reusable helpers (`Duration.toTimecode()`), never for hidden business logic.

## Size & shape
- Function ≤ ~30 lines, file ≤ ~250 lines, `build()` ≤ ~120 lines → extract widgets (classes, not helper
  methods returning `Widget`).
- Max 3 levels of nesting; use guard clauses.
- One reason to change per class (SRP). Depend on abstractions (DIP). Extend by adding implementations (OCP).

## Comments
- Default: no comments. Names carry the meaning. Comment only the **why** of non-obvious logic (timing
  maths, platform quirks, workaround with a link). No commented-out code, no TODO without owner/issue.
- Public APIs of `core/` get one-line dartdoc.

## Async
- `Future`/`Stream` only at boundaries; keep domain logic synchronous where possible.
- Always cancel subscriptions/timers/controllers. Use `CancelToken`-style cancellation for long jobs.
- Never `await` in a loop when work is independent — but never fan out unbounded CPU work (ASR) either.

## Localization
- All user-visible strings via `l10n` (ARB), Arabic is the primary locale, English secondary.
- No string concatenation for sentences; use ICU placeholders/plurals. Numerals: format via `intl`.

## Lints
- `very_good_analysis`; `strict-casts`, `strict-inference`, `strict-raw-types` on. Zero analyzer warnings
  to merge. `dart format` (80 cols) enforced.
