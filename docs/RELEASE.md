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
1. Open `ios/Runner.xcworkspace`, set Team + signing for bundle id `com.megtech.tarjuman` (or your own).
2. `flutter build ipa --release` then upload with Transporter / Xcode Organizer.

## Before every release
`flutter analyze` clean · `flutter test` green · run the release build on a real device · bump version.

## 16 KB check (Google Play requirement for Android 15+ targets)
```bash
unzip -oq dist/tarjuman-*-arm64.apk 'lib/arm64-v8a/*.so' -d /tmp/libs
python3 - <<'PY'
import struct,glob
for f in sorted(glob.glob('/tmp/libs/lib/arm64-v8a/*.so')):
    d=open(f,'rb').read(); off=struct.unpack_from('<Q',d,0x20)[0]; sz,n=struct.unpack_from('<HH',d,0x36)
    al=[struct.unpack_from('<IIQQQQQQ',d,off+i*sz)[7] for i in range(n) if struct.unpack_from('<I',d,off+i*sz)[0]==1]
    print('OK ' if min(al)>=0x4000 else 'BAD', f.split('/')[-1], hex(min(al)))
PY
```
Every line must say `OK`.
