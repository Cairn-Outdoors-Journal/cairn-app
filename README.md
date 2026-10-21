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
| Regenerate database code | `dart run build_runner build` |
| Snapshot the schema after a change | `dart run drift_dev make-migrations` |
| Inspect stored data on a device | `flutter run -t lib/dev/data_inspector/main.dart` |
| Try the shelf with sample notebooks | `flutter run -t lib/dev/sample_shelf/main.dart` |

Android needs Android 12 (API 31) or later.

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
  features/            one folder per screen or flow
    shelf/             the bookshelf: covers, new/edit sheet, long-press actions
    notebook/          an open notebook (placeholder until stage 7b)
    unlock/            unlocking a restored journal with the recovery key
  data/                the journal on the phone (ADR 0010)
    journal.dart       opens everything; screens use its repositories
    database/          drift tables and the encrypted SQLite database
    repositories/      notebooks, pages, page items, pocket, location points
    media/             photos and other files, encrypted with libsodium
    keys/              master key in the Keychain / Keystore, recovery key, subkeys
    sync/              hybrid logical clock and the change log
  dev/                 developer tools (data inspector, sample shelf)
  spikes/              test builds from stage 5
drift_schemas/         schema snapshots; migration tests in test/drift/
```

Everything in `data/` is encrypted on the phone: the database with SQLite3MultipleCiphers (set in
the `hooks:` section of `pubspec.yaml`) and each media file with XChaCha20-Poly1305. The keys come
from the account master key, kept in the Keychain / Keystore and written out for the person as
their recovery key. OS backups include the encrypted journal (on Android, cloud backup holds the
database but not photos); where the key doesn't come back with it, the recovery key unlocks it.

Planned: the sync engine and storage providers in `data/`, and `api/` (client generated from the
pinned `openapi.json` of cairn-api).
