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

## Simulators

The team uses an iPhone 18 Pro simulator and the `Medium_Phone_API_37.0` Android emulator; swap in
your own names from `xcrun simctl list devices` and `emulator -list-avds`.

```sh
# iPhone simulator, with its window (Xcode 27 replaced the Simulator app with DeviceHub)
xcrun simctl boot "iPhone 18 Pro"
open /Applications/Xcode.app/Contents/Applications/DeviceHub.app

# Android emulator, in the background
emulator -avd Medium_Phone_API_37.0 > /dev/null 2>&1 &
```

Then run the app on one or both:

```sh
flutter run -d "iPhone 18 Pro"
flutter run -d emulator-5554
flutter run -d all
```

- In `flutter run`, `r` reloads code and `R` restarts the app. After a database schema change,
  quit with `q` and run again.
- Launching from the simulator's home screen opens the last build installed, which may be old.
- The iPhone simulator shuts down when its DeviceHub window is closed; boot it again.
- Light or dark mode: `xcrun simctl ui "iPhone 18 Pro" appearance dark` (or `light`) and
  `adb shell cmd uimode night yes` (or `no`).
- `flutter devices` lists what's running.
- An emulator whose screen has gone to sleep draws nothing, so on-device tests wait forever. Keep
  it awake while plugged in: `adb shell svc power stayon true`.

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
    notebook/          an open notebook: pages side by side, the Days tab, the opening animation
    page/              a day page: fixed-size page, stamped header, templates, writing
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

Pages are a fixed 432 × 792 points (6 × 11 in) on every phone, scaled to fit the screen, so a
page that's full on one phone is full on all. Writing that runs past the bottom continues on the
next page for the same day. Today's page is stored only once something is written on it.

Planned: the sync engine and storage providers in `data/`, and `api/` (client generated from the
pinned `openapi.json` of cairn-api).
