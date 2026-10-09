# Tarjuman (ترجمان) — Brand Guidelines v1.0

Visual reference: `docs/design/brand-and-screens.html` (open in a browser; includes all screens, light + dark).
Code mapping: `lib/core/design_system/` (tokens listed below are the exact values to implement).

---

## 1. Brand

| | |
|---|---|
| Name | **ترجمان** · Tarjuman *(working name)* |
| Meaning | "The interpreter" — someone who stands between two languages and makes both understood. |
| Promise | **شاهد أي فيديو بالعربي، بدون إنترنت.** Watch any English video in Arabic, even offline. |
| Personality | Cinematic · precise · calm · trustworthy. A tool that disappears while you watch. |
| Audience | Arabic speakers learning from English video (courses, talks, tutorials, films), 16–45. |
| Voice | Direct, warm Modern Standard Arabic with light Egyptian-friendly simplicity. Short sentences, verbs first. No hype, no apologies. |

### Brand idea: "the subtitle line"
The product *is* a line of text at the bottom of a screen. The brand borrows that: a **screen frame** with a
**saffron caption bar**. Saffron is the colour of classic yellow subtitles — it instantly says "subtitles"
and gives the dark, video-first UI one warm focal point.

### Voice examples
| Situation | Say | Don't say |
|---|---|---|
| Start processing | "ابدأ الترجمة" | "يرجى الضغط لبدء عملية المعالجة" |
| Offline ready | "جاهز بدون إنترنت" | "تم تحميل النماذج بنجاح" |
| Error – no model | "حمّل نموذج الإنجليزية أولاً (٤٠ ميجا)" | "حدث خطأ غير متوقع" |
| Empty library | "أضف أول فيديو وشاهده بالعربي" | "لا توجد عناصر" |

## 2. Logo

- **Mark:** rounded-square screen (radius 28 % of side) holding two caption lines — a short ink line above
  and a longer saffron line below — representing original → translated subtitle.
- **Lockup:** mark + "ترجمان" in Reem Kufi 700; Latin "Tarjuman" in IBM Plex Sans 600 as secondary line only
  when space allows.
- **Clear space:** ½ mark height on all sides. **Min size:** 24 dp mark, 96 dp lockup.
- **Colours:** on dark → saffron bar + white frame line; on light → ink frame + saffron bar; mono version = single colour.
- **Don't:** rotate, outline, add gradients/shadows, recolour the bar, put on busy video frames without a scrim.
- App icon: mark on Ink 950, saffron bar, full-bleed (Android adaptive foreground = mark at 66 % safe zone).

## 3. Colour

Dark theme is the primary experience (video-first). Light theme is complete and equal-quality.

| Token | Dark | Light | Use |
|---|---|---|---|
| `bg` | `#0A0D14` | `#F5F6FA` | App background (blue-biased ink, never pure black) |
| `surface` | `#11151F` | `#FFFFFF` | Cards, sheets |
| `raised` | `#1A2030` | `#ECEFF5` | Inputs, chips, pressed states |
| `line` | `#262E42` | `#DCE0EA` | Dividers, borders (1 dp) |
| `text` | `#EEF1F7` | `#111827` | Primary text |
| `muted` | `#8E98AE` | `#596277` | Secondary text, captions |
| `primary` (Saffron) | `#FFC93C` | `#F5B800` | CTAs, active cue, key focus. Text on it: `onPrimary` `#1A1405` |
| `primaryText` | `#FFC93C` | `#8A6100` | Saffron used **as text/icon on surface** (light needs the deep tone for contrast) |
| `signal` (Lagoon) | `#35D0BA` | `#0B8F7F` | Offline / ready / success / local processing |
| `info` | `#6FA8FF` | `#2F6FDB` | Online mode, links, neutral information |
| `error` | `#FF6B6B` | `#D93A3A` | Failures, destructive |
| `scrim` | `#0A0D14` @ 72 % | same | Behind subtitles and over video |

Rules
- **One accent per screen region.** Saffron = "the thing to press / the thing being said". Lagoon = system state.
  Never use both as fills in the same component.
- Saffron fills always carry `onPrimary` text. Saffron text on `surface` only in dark theme or via `primaryText`.
- Offline = lagoon, Online = info blue — users must always be able to tell which mode processed a video.
- Contrast: all text pairs ≥ 4.5:1, UI boundaries ≥ 3:1 (verified for every pair above).

### Subtitle colour presets (user-selectable)
White `#FFFFFF` · Saffron `#FFC93C` · Lagoon `#35D0BA` · Soft grey `#D6DAE4`. Background modes: scrim box (default),
outline only, none.

## 4. Typography

| Role | Font | Weights | Notes |
|---|---|---|---|
| Brand / large titles | **Reem Kufi** | 600, 700 | Logo, screen hero titles ≥ 28 sp only |
| UI + body + subtitles | **IBM Plex Sans Arabic** | 400, 500, 600, 700 | Excellent Arabic + matching Latin; neutral and legible on video |
| Timecodes, sizes, ETA | **IBM Plex Mono** | 500 | Always LTR, tabular figures |

Bundle all fonts as assets (offline app).

| Style | Size / line-height | Weight | Font |
|---|---|---|---|
| `display` | 32 / 40 | 700 | Reem Kufi |
| `title` | 22 / 30 | 600 | Plex Arabic |
| `heading` | 18 / 26 | 600 | Plex Arabic |
| `body` | 16 / 26 | 400 | Plex Arabic |
| `label` | 14 / 20 | 500 | Plex Arabic |
| `caption` | 12 / 18 | 400 | Plex Arabic |
| `subtitle` (on video) | 22 / 32 (user 16–36) | 500 | Plex Arabic |
| `timecode` | 13 / 18 | 500 | Plex Mono |

Rules: Arabic line-height ≥ 1.5 (subtitles ≥ 1.4) · no letter-spacing on Arabic · max 2 subtitle lines ·
numerals: Eastern-Arabic (٠١٢) by default in UI copy, Western in timecodes/file sizes · support 200 % text scale.

## 5. Layout, shape, depth

- **Grid:** 4-pt base. Spacing tokens `xs 4 · sm 8 · md 12 · lg 16 · xl 24 · xxl 32 · huge 48`. Screen gutter 20.
- **Radius:** `sm 8` (chips, inputs) · `md 12` (buttons, list rows) · `lg 20` (cards) · `xl 28` (sheets, phone-level surfaces) · `pill 999`.
- **Depth:** mostly tonal (bg → surface → raised). Shadow only for floating layers (sheets, player controls): blur 24, y 8, 40 % ink.
- **Cards:** use sparingly — only to separate a distinct object (video, model). Lists inside a section use dividers, not cards.
- **Touch targets** ≥ 48 dp; primary CTA height 52; compact controls 40 with 48 hit area.
- **Icons:** 24 dp rounded-outline set (Material Symbols Rounded, weight 400, optical size 24), 1.75 dp stroke feel; saffron only for the active state.

## 6. Components (all must exist in the design system)

`AppButton` primary / secondary / ghost / destructive · `AppChip` (filter, choice) · `StatusPill` (offline, online,
processing, ready, failed) · `AppProgressBar` (determinate + indeterminate) · `StageStepper` (extract → transcribe →
translate) · `VideoCard` (thumbnail, duration, status, language chip) · `AppBottomSheet` · `AppSwitchTile` ·
`AppSlider` (with live value) · `ColorPresetPicker` · `CueTile` (timecodes + original + Arabic) · `ModelTile`
(name, size, quality, state: not-downloaded / downloading / ready) · `SubtitleView` · `PlayerControls`.

States for each: default · pressed · focused · disabled · loading · error. Both themes. RTL.

## 7. Motion

Fast and quiet; never compete with the video.
- Micro 150 ms · transition 250 ms · sheet 400 ms. `easeOutCubic` in, `easeInCubic` out.
- Subtitle cue change: 120 ms cross-fade (no movement). Player controls: fade 200 ms, auto-hide after 3 s.
- Processing: stage dot pulses (1.2 s) while active; progress bar shimmers only when indeterminate.
- Reduce-motion: replace transitions with instant state changes.

## 8. Screens (see HTML board)

1. **Library** — recents, status per video, FAB "إضافة فيديو".
2. **Import** — local file / direct link, processing mode (pre-process vs. live), offline/online toggle.
3. **Processing** — three-stage stepper, determinate progress, ETA, "play while processing" for live mode.
4. **Player** — full-bleed video, `SubtitleView`, transport controls (LTR), speed, subtitle toggle, style entry.
5. **Subtitle style sheet** — size, colour preset, background mode, position, live preview.
6. **Subtitle editor** — cue list with timecodes, original EN above AR, tap to edit, jump-to-time, export SRT.
7. **Model manager** — speech + translation models, size, quality, free space, download/remove.
8. **Settings** — default mode, online consent, language, theme, storage.

Every screen designs 4 states: loading, empty, error, offline.

## 9. Do / Don't

Do: let the video be the hero · keep chrome minimal · show *which mode* produced a subtitle · always show model sizes
before downloading · give every wait a stage + ETA.
Don't: add decorative gradients · use pure black/white · stack more than one saffron element per region · hide
offline/online state · show raw error codes.
