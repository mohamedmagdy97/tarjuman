# UI & design-system rules

Source of truth: `docs/BRAND_GUIDELINES.md` (tokens, rules) and `docs/design/brand-and-screens.html` (visual
reference for every screen). If code and design disagree, flag it — don't silently drift.

## Tokens only
- Everything visual comes from `lib/core/design_system/`:
  `AppColors` (ThemeExtension, light + dark), `AppTypography`, `AppSpacing` (4-pt grid: 4, 8, 12, 16, 20,
  24, 32, 48), `AppRadius`, `AppElevation`, `AppMotion` (durations/curves).
- Access via `context.colors`, `context.text`, `AppSpacing.md` etc. **Never** `Color(0x…)`, `Colors.*`,
  raw font sizes, or numeric paddings in feature code.
- Dark theme is the hero (video-first); light theme must be complete and tested.

## Components
- Build atoms → molecules → organisms in `core/design_system/components/`:
  `AppButton` (primary/secondary/ghost, sizes), `AppChip`, `StatusPill`, `AppProgressBar`, `StageStepper`,
  `AppCard`, `AppListTile`, `AppBottomSheet`, `AppSwitchTile`, `AppSlider`, `SubtitleView`, `VideoCard`.
- Feature widgets compose these. If a pattern appears twice, promote it to the design system.
- Every component: stateless where possible, `const`-constructible, all states (default, pressed, disabled,
  focused, loading, error) and both themes. Golden tests for the core set.

## RTL & Arabic
- App is RTL by default (`Directionality` from locale). Use directional APIs only
  (`EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`).
- Icons that imply direction (back, next, progress) must mirror; media transport controls (play/seek bar)
  stay **LTR** like every video player.
- Timecodes and Latin text inside Arabic: wrap with LTR isolates; use tabular figures for timecodes.
- Fonts: IBM Plex Sans Arabic (UI/subtitles), Reem Kufi (logo + large titles only), IBM Plex Mono (timecodes).
  Bundle them as assets (no runtime Google Fonts fetch → app must work offline).
- Arabic line-height ≥ 1.5 for body, ≥ 1.4 for subtitles; never letter-space Arabic text.

## Accessibility
- Touch targets ≥ 48 dp. Contrast ≥ 4.5:1 text, 3:1 UI. Support system font scale up to 200% (no clipped text).
- `Semantics` labels in Arabic for icon-only buttons; subtitle view announces nothing while video plays.
- Respect `MediaQuery.disableAnimations`.

## Subtitle rendering (the product's core UI)
- `SubtitleView` is a standalone widget: inputs = active cue, `SubtitleStyle` (size, color preset, background
  mode, position, weight). Never reads the player directly.
- Default look: Saffron-tinted white text on 72% ink scrim, 22 sp, max 2 lines, safe-area aware, never overlaps
  transport controls (lifts when controls are visible).
- Style changes apply instantly with live preview; persisted through `SettingsStore`.

## Motion
- 150 ms (micro), 250 ms (transitions), 400 ms (sheets). Curves: `easeOutCubic` in, `easeInCubic` out.
  Subtitle cue change = 120 ms cross-fade, no slide. Progress uses determinate bars when ETA is known.

## Screens (see design board)
Library · Import · Processing · Player · Subtitle style sheet · Subtitle editor · Model manager · Settings.
Each has loading / empty / error / offline states designed — implement all four, not only the happy path.
