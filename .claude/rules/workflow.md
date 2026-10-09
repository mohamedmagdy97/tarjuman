# Workflow rules

## Git
- **Never commit, push, or create PRs unless the owner asks.** Report changes and offer.
- When asked: Conventional Commits (`feat(player): …`, `fix(processing): …`), one logical change per commit,
  branch per feature (`feat/…`, `fix/…`). Verify `git branch --show-current` before committing.
- Never run `git reset --hard`, `git clean`, or force-push without first running `git status` + `git diff`
  and getting a yes (an uncommitted-edit wipe has already happened on another project).

## Before writing code for a task
1. Identify the layer(s) and feature touched; check if a port/use case/component already exists.
2. If it needs a new package: justify, check license + maintenance, hide behind an adapter, ask first.
3. Write/adjust domain + tests first for logic-heavy work (timeline, parsing, pipeline).

## Definition of done
- `flutter analyze` clean · tests added/updated and green · no raw colors/sizes · RTL verified ·
  Arabic strings in ARB · all 4 UI states handled (loading/empty/error/offline) · no layer violations.
- For ASR/translation/player/perf tasks: verified in **release mode on a device** (state which).
- Update `docs/` if a decision, license, or contract changed (`docs/LICENSES.md`, `docs/DECISIONS.md`).

## Decisions log
Record significant choices as short ADRs in `docs/DECISIONS.md` (context → decision → consequences), e.g.
"Whisper binding choice", "FFmpeg vs native extraction". Link to benchmark numbers.

## Dependencies & licenses
- Add each model/package to `docs/LICENSES.md` (name, version, license, commercial use? yes/no).
- Models are downloaded on demand (never bundled) and show size + free storage before download.

## Communication
- Owner prefers a concrete recommendation over a survey of options. Be explicit about trade-offs in 2–3 lines.
- Say so when something is unverified (not run on device / not tested).
