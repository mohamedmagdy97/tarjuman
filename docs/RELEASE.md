# Release guide

## Android
Signing: `android/key.properties` + `android/app/upload-keystore.jks` (both git-ignored, created 2026-10-09).
**Back both files up outside the repo** (password manager / encrypted drive). Losing the keystore means you can
never update the app on Google Play (unless you enrol in Play App Signing and reset the upload key).

```bash
flutter build apk --release --split-per-abi   # sideload / testers: build/app/outputs/flutter-apk/
flutter build appbundle --release             # Google Play: build/app/outputs/bundle/release/app-release.aab
```
Bump `version:` in `pubspec.yaml` (`1.0.1+2`; the number after `+` must increase every upload).
Release config: R8 minify + resource shrinking on, `minSdk 24`. Add keep rules to `android/app/proguard-rules.pro`
when ASR/translation plugins are added.

## iOS (needs the owner's Apple account)
1. Open `ios/Runner.xcworkspace`, set Team + signing for bundle id `tech.megtech.tarjuman` (or your own).
2. `flutter build ipa --release` then upload with Transporter / Xcode Organizer.

## Before every release
`flutter analyze` clean · `flutter test` green · run the release build on a real device · bump version.
