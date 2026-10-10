# Google Play — launch checklist (Tarjuman)

Everything the app can generate is already in `store/`. This file is what **you** do in Play Console.

## 0. Before you start — decisions that are permanent
- [x] **Package name: `com.megtech.tarjuman`** (final — it cannot change after the first upload).
- [ ] **App name:** `Tarjuman` is a working name. Confirm the final Arabic/English names in `store/listing/*.md`.
- [ ] **Back up** `android/key.properties` and `android/app/upload-keystore.jks` outside the repo. Use Play App Signing
      (Console → Setup → App signing): Google keeps the real signing key, ours is only the *upload* key, which Google
      can reset if it is ever lost.

## 1. Account
- [ ] Google Play developer account (one-time registration fee, identity verification).
- [ ] **Personal accounts created after Nov 2023** must run a *closed test with at least 12 testers for 14 consecutive days*
      before they can apply for production access. Verify the current rule in Play Console → Dashboard. Plan for it:
      invite testers early. (Organization accounts are exempt.)

## 2. Create the app
- App name, default language **Arabic**, add English. App (not game), **Free**.
- Declarations: contains ads → **No**. Government/financial/health/news → No.

## 3. Store listing (copy from `store/listing/ar.md`, `en.md`)
| Field | File |
|---|---|
| App icon 512×512 | `store/android/icon-512.png` |
| Feature graphic 1024×500 | `store/android/{ar,en}/upload/feature-graphic-1024x500.jpg` |
| Phone screenshots (8, 1080×1920) | `store/android/{ar,en}/upload/phone-screenshots/*.jpg` |
| Short / full description, release notes | `store/listing/` |
| Privacy policy URL | `https://mohamedmagdy97.github.io/tarjuman-privacy/` (publish `store/privacy-site/` to that repo, see §3b) |
Screenshots are rendered from the app's real screens with sample content (library, player, processing, setup, models,
subtitle style, editor, settings). Play accepts JPEG/24-bit PNG without alpha: the `upload/` copies are alpha-free.
Original PNG masters and raw screens are in `store/android/{ar,en}/` and `store/raw/`.

## 3b. Publish the privacy policy (GitHub Pages)
```bash
cd store/privacy-site
git init -b main && git add . && git commit -m "Privacy policy"
git remote add origin https://github.com/mohamedmagdy97/tarjuman-privacy.git
git push -u origin main
```
Then GitHub → repo **Settings → Pages → Deploy from a branch → main / (root)**. Open
https://mohamedmagdy97.github.io/tarjuman-privacy/ and confirm it loads **before** pasting it in Play Console.
(The same URL is already linked from the app: Settings → Privacy policy.)

## 4. App content
- **Privacy policy:** URL from step 3b (support email `mohammedmagdy823@gmail.com` is already in it).
- **Data safety** (suggested answers — review them yourself, you are responsible for accuracy):
  - Does the app collect or share required user data types? **No data collected by the developer.**
  - Optional online mode: when the user enables it and supplies their own OpenAI key, **audio** (and derived text) is sent to
    OpenAI for processing → declare *Audio files* as **shared**, purpose *App functionality*, **optional**, encrypted in transit.
  - Data deletion: nothing is stored server-side by us; users delete local data in-app or by uninstalling.
- **Content rating** questionnaire: no violence/sexual content/gambling/UGC sharing → expected "Everyone".
- **Target audience:** 13+ / adults, **not** designed for children.
- **App access:** all features available without login.
- Ads: none. Permissions: only `INTERNET` (mic permission is explicitly removed from the manifest).

## 5. Release
1. Console → Testing → **Internal testing** → upload `dist/tarjuman-<version>.aab` → add yourself → install from the Play link.
   Run the on-device checklist in `.claude/rules/testing.md` (release mode, real phone).
2. Fix what internal testing finds, bump `version:` in `pubspec.yaml` (`+N` must increase for every upload).
3. **Closed testing** (12+ testers, 14 days if required) → apply for production.
4. Production rollout, ideally staged (10 % → 50 % → 100 %).
5. Read the **Pre-launch report** Play generates (crashes, accessibility).

## 4b. Permissions
The app asks for **no sensitive permissions**: only `INTERNET` (and normal-level `ACCESS_NETWORK_STATE`/`WAKE_LOCK`).
Videos are picked with the system photo/video picker or file browser, which need no permission and no Play declaration.
Do not add `READ_MEDIA_VIDEO`/`READ_EXTERNAL_STORAGE`/`MANAGE_EXTERNAL_STORAGE`: they trigger extra policy forms.

## 5b. Technical gates already satisfied by this build (verify again after any dependency change)
- `targetSdk 36`, `minSdk 24`, AAB, signed with the upload key.
- **16 KB page size:** all native `.so` must have ELF `p_align >= 0x4000`. `android/build.gradle.kts` forces NDK r28 +
  `ANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES` on plugin modules (the whisper plugin was 4 KB-aligned before). Re-check with the
  script in `docs/RELEASE.md` ("16 KB check").
- Native debug symbols (`SYMBOL_TABLE`) are bundled in the AAB for readable native crash reports.

## 6. Licenses (already handled in-app, keep it that way)
- In-app Settings → Open-source licenses lists Dart packages plus FFmpeg (LGPL), Whisper (MIT) and the fonts (OFL).
- Never swap `ffmpeg_kit_flutter_new_audio` for the GPL packages (would force the whole app to GPL).
- Review ML Kit's terms (`docs/LICENSES.md`) before enabling any paid tier.

## 7. After launch
- Reply to reviews, watch Android vitals (crashes/ANRs). Consider adding Sentry/Crashlytics.
- Known product limits to mention in support replies: needs a one-time model download; machine translation can err;
  only direct file links; iOS version not released yet.
