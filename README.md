# ShareDrop for iPhone — native SwiftUI

ShareDrop is a native SwiftUI iOS app with a dark, custom Liquid Glass-inspired interface. The first iPhone milestone includes:

- A redesigned ShareDrop home screen and native Liquid Glass surfaces.
- Native Files document picker for documents, PDFs, videos, archives, and other file types.
- Native Photos picker for selecting up to 12 images at once.
- Local staging of selected files inside the app's temporary directory.
- A native iOS share sheet for choosing an available destination.
- A lightweight Activity screen listing files prepared during the current app session.

## Current limitation — read before testing

This is the first ShareDrop iPhone UI and file-selection milestone. It does **not yet implement ShareDrop-specific nearby-device discovery or direct cross-platform transfer between the iPhone, Android, and Windows app**. For now, the final sharing action opens the iOS system share sheet. The next development milestone is to implement and test the actual device-to-device transfer protocol.

## Liquid Glass

The project targets iOS 26.0 or later and uses native SwiftUI `glassEffect` and glass button styles. The system controls and materials use Apple's native rendering, while custom surfaces keep a deliberately dark, blue-accented ShareDrop identity. See Apple's SwiftUI documentation for [`glassEffect`](https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:)).

## Build the unsigned IPA from Windows

The `.github/workflows/build-ipa.yml` workflow uses a GitHub-hosted macOS runner with Xcode. Xcode does not need to be installed on the Windows PC.

1. Extract this project to a new folder, such as `E:\Documents\ShareDrop-iOS-0.2.0`.
2. Copy its contents into the existing `TheRealRaphaelYT/iPhoneStarter` repository working copy, or replace the tracked files in a clean clone of that repository. Do not nest the project in another project folder.
3. Commit and push the changes to `main`.
4. Open **Actions** in the GitHub repository and monitor **Build ShareDrop iOS IPA**.
5. After a successful run, download the `ShareDrop-unsigned-IPA` artifact and extract the ZIP artifact to obtain `ShareDrop-unsigned.ipa`.
6. The workflow creates an **unsigned** IPA. Use the existing signing/installation tool to sign it with the appropriate certificate and provisioning method.

## Important project settings

- Display name: `ShareDrop`
- Xcode project/scheme name: `iPhoneStarter` (kept stable so the existing workflow and project structure continue to work)
- Bundle identifier: `com.therealraphael.iphonestarter` (kept stable so this build can update the installed starter app when signing identity and installation tool allow it)
- Deployment target: iOS 26.0+
- UI framework: SwiftUI
- Build runner: GitHub Actions / macOS 26

## Data handling in this milestone

Selected documents and photos are copied into the app's temporary directory before sharing. This version does not upload them to a ShareDrop server. The chosen destination in Apple's share sheet determines what happens next. Direct ShareDrop transfer, receiving mode, peer discovery, authentication, and persistent transfer history are not implemented yet.
