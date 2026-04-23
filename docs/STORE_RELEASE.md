# Releasing to Google Play and Apple App Store

Your IDs are aligned for production: **Android** and **iOS** both use `com.sportfinding.app` (same as Firebase).

## Version numbers

- Bump in `pubspec.yaml`: `version: x.y.z+build`  
  - `x.y.z` = user-facing version (Play/App Store)  
  - `build` = `versionCode` (Android) / build number (iOS) — must increase for every store upload.

## Google Play (Android)

1. **Release keystore** — `android/create_release_keystore.sh`, then `key.properties` (see `key.properties.example`). **Back up** `upload-keystore.jks` and passwords off this machine.
2. **Register release SHA-1/SHA-256** in Firebase for `com.sportfinding.app` (and Play App signing cert from Play Console if you use Play App Signing).
3. Build: `flutter build appbundle`  
4. [Play Console](https://play.google.com/console) — create the app, upload the `.aab`, complete store listing, **Privacy policy** URL, content rating, **Data safety** form.
5. **Internal / closed testing** first, then production rollout.

## App Store (iOS)

1. **Apple Developer** — enroll; create **App ID** for `com.sportfinding.app` (matches Xcode).
2. **Certificates & profiles** — Distribution certificate, **App Store** provisioning profile for the Runner app (Xcode: Signing & Capabilities).
3. **Add `GoogleService-Info.plist`** — Firebase → Project settings → iOS app → download and place in `ios/Runner/` (optional but recommended; keys are also in `Info.plist` for Google Sign-In).
4. `open ios/Runner.xcworkspace` — select **Any iOS Device (arm64)** → **Product → Archive** → Distribute to **App Store Connect** (or `flutter build ipa` with signing configured).
5. **App Store Connect** — new app, **Privacy nutrition labels**, review notes, **TestFlight** beta then submit for review.

## Commands

```bash
# Android App Bundle
flutter build appbundle

# iOS (needs signing in Xcode or CI)
flutter build ipa
```

## Checklist

| Item | Play | App Store |
|------|------|-----------|
| Privacy policy URL | required | required (often linked in App Privacy) |
| Sign-in (Google) SHA / OAuth | Firebase + Play signing | N/A (OAuth via plist) |
| Location/camera/photo usage text | in-app copy | `Info.plist` strings (you have them) |
| Age rating / questionnaire | Play form | age rating in ASC |

## After launch

- Monitor **Play Console** / **App Store Connect** for crashes, reviews, and policy messages.
- For updates: bump `pubspec` version, rebuild, upload new AAB/IPA.
