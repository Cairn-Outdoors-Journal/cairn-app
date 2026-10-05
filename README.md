# cairn-app

The Cairn mobile app for iOS and Android, built with Flutter. Product context, architecture and
decisions live in [cairn-product-hub](https://github.com/Cairn-Outdoors-Journal/cairn-product-hub).

- **App ID:** `com.cairnjournal.app` (iOS bundle identifier and Android application ID)
- **Flutter:** 3.47.6 (stable), Dart 3.13

## Setup

```sh
brew install --cask flutter    # or follow flutter.dev/docs/get-started
flutter pub get
```

Running on devices and simulators also needs Xcode (iOS) and Android Studio (Android).

## Commands

| Task | Command |
|---|---|
| Run | `flutter run` |
| Test | `flutter test` |
| Analyze | `flutter analyze` |
| Format | `dart format lib test` |

CI runs the format check, analysis and tests on every pull request and on `main`
([.github/workflows/ci.yml](.github/workflows/ci.yml)). Release builds to TestFlight and Google Play
internal testing will be added once signing is set up.

## Structure

```
lib/
  main.dart            entry point
  app.dart             MaterialApp, themes, router
  router.dart          routes
  design/              colour tokens (ADR 0005) and themes
  features/            one folder per screen or flow (shelf/, notebook/, page/, pocket/, ...)
```

Planned, per the architecture: `data/` (SQLite via drift, media store, sync engine, storage
providers) and `api/` (client generated from the pinned `openapi.json` of cairn-api). Native
extensions (widget, Action button, quick-settings tile) will live under `ios/` and `android/`.
