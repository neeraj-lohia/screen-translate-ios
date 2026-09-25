# ScreenTranslate

An iOS app that mimics Android's "Circle to Search" screen translation:
press a Shortcut (bound to the iPhone Action Button), it grabs whatever is on
screen, runs on-device OCR (Vision framework) + on-device translation
(Translation framework, German -> English), and overlays the translated text
directly on top of the original, in place.

iOS does not allow any app to draw over other apps or capture their screen
live in the background, so this can't be a true system-wide overlay like
Android's. The closest faithful equivalent: a 2-step Shortcut takes a
screenshot and hands it to this app, which briefly foregrounds and shows the
translated overlay full-screen.

## How it works

1. `TranslateScreenshotIntent` (App Intents) receives an image handed to it
   by the Shortcuts app.
2. `OCRTranslator` runs `VNRecognizeTextRequest` to find text + bounding boxes.
3. `TranslateOverlayView` batch-translates every recognized line with the
   `Translation` framework and draws each translation directly over its
   original bounding box.

You can also test the OCR/translate pipeline directly from the app's home
screen via "Or pick a photo to test" (no Shortcut needed).

## Building (CI, no Mac required)

`.github/workflows/build-ipa.yml` builds an **unsigned** `.ipa` on a
GitHub-hosted macOS runner using [XcodeGen](https://github.com/yonaskolb/XcodeGen)
(`project.yml` -> `.xcodeproj`) and plain `xcodebuild`. Every push to `main`
triggers a build; grab the `ScreenTranslate-ipa` artifact from the workflow
run.

It's unsigned on purpose - signing happens on your PC during sideloading
(next section), so no Apple credentials ever need to touch CI.

## Installing on your iPhone without a Mac (AltStore)

You only need a Windows PC, a USB cable, and a free Apple ID.

1. Install **iTunes** (or Apple Devices app) from the Microsoft Store/Apple
   so Windows can talk to the iPhone over USB.
2. Install **AltServer** for Windows: https://altstore.io
3. Plug in your iPhone, trust the computer, and run AltServer (it lives in
   the system tray).
4. In the AltServer tray icon menu: **Install AltStore -> (your iPhone)**,
   sign in with your Apple ID when prompted (used locally, only to talk to
   Apple's servers directly).
5. On the iPhone, go to **Settings -> General -> VPN & Device Management**
   and trust the new developer profile.
6. Back on the PC, download `ScreenTranslate.ipa` from the Actions artifact.
7. AltServer tray icon -> **Install .ipa** -> pick the file -> choose your
   iPhone. It signs it with your Apple ID and installs it.

Free Apple ID apps expire after **7 days**. Keep AltServer's "AltStore" app
open on your phone with Wi-Fi on the same network as your PC and it will
auto-refresh; otherwise just re-run step 7 weekly. A $99/year Apple Developer
account removes this limit entirely (1-year certs, or distribute via
TestFlight instead).

## Wiring up the Action Button

1. Open the **Shortcuts** app -> **+** -> name it e.g. "Translate Screen".
2. Add action **Take Screenshot**.
3. Add action **Translate Screenshot** (search for it - it's exposed by the
   ScreenTranslate app itself) and pass in the screenshot from step 2.
4. Settings -> **Action Button** -> **Shortcut** -> choose "Translate Screen".
   (No Action Button? Settings -> Accessibility -> Touch -> Back Tap ->
   Double Tap -> same shortcut.)

Press the Action Button from any app -> ScreenTranslate opens showing the
frozen screen with translations overlaid in place.
