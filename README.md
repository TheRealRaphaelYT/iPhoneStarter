# ShareDrop for iPhone — native SwiftUI (0.2.2, 1024px icon setup)

ShareDrop is a native SwiftUI iOS app with a dark, custom Liquid Glass-inspired interface. This milestone includes:

- Redesigned ShareDrop home screen and native Liquid Glass surfaces.
- Native Files document picker and Photos picker.
- Local staging of selected files inside the app's temporary directory.
- Native iOS share sheet.
- App Icon asset catalog wired into the Xcode project and cloud build.

## Add your 1024x1024 app icon

Replace this exact file with your own **1024x1024 pixel PNG**:

`iPhoneStarter/Branding/ShareDropIcon-1024x1024.png`

Keep the filename exactly `ShareDropIcon-1024x1024.png`. This is the source image used by the GitHub Actions workflow.

The workflow verifies that the PNG is exactly 1024x1024, then copies it directly to the Xcode app icon asset:

`iPhoneStarter/Assets.xcassets/AppIcon.appiconset/AppIcon.png`

No resizing is performed. Do not rename or delete `Contents.json` in that folder; it tells Xcode which image is the app icon. You only need to replace the source PNG in `Branding`.

For best App Store compatibility, use a square 1024x1024 PNG without a transparent background.

## Build the unsigned IPA from Windows

The `.github/workflows/build-ipa.yml` workflow uses a GitHub-hosted macOS runner with Xcode. Xcode does not need to be installed on the Windows PC.

1. Replace `iPhoneStarter/Branding/ShareDropIcon-1024x1024.png` with your own 1024x1024 PNG, keeping the same filename.
2. Copy these project files into the existing `TheRealRaphaelYT/iPhoneStarter` repository working copy (or replace the tracked files in a clean clone).
3. Commit and push the changes to `main`.
4. Open **Actions** in the GitHub repository and monitor **Build ShareDrop iOS IPA**.
5. After a successful run, download the `ShareDrop-unsigned-IPA` artifact and extract the ZIP artifact to obtain `ShareDrop-unsigned.ipa`.
6. The workflow creates an **unsigned** IPA. Use your existing signing/installation tool to sign it with the appropriate certificate and provisioning method.

## Important project settings

- Display name: `ShareDrop`
- Xcode project/scheme name: `iPhoneStarter` (kept stable so the workflow and project structure continue to work)
- Bundle identifier: `com.therealraphael.iphonestarter` (kept stable so this build can update the installed app if signing and installation method allow it)
- Deployment target: iOS 26.0+
- UI framework: SwiftUI
- App icon asset name: `AppIcon`
- App icon source file: `iPhoneStarter/Branding/ShareDropIcon-1024x1024.png`
- Build runner: GitHub Actions / macOS

## Current transfer limitation

This is the iPhone UI and file-selection milestone. It does **not yet implement ShareDrop-specific nearby-device discovery or direct cross-platform transfer between iPhone, Android, and Windows**. The final sharing action uses the iOS system share sheet. Direct ShareDrop transfer and receiving mode are future development work.

## Data handling

Selected documents and photos are copied into the app's temporary directory before sharing. This version does not upload them to a ShareDrop server. The destination selected in Apple's share sheet determines what happens next. Direct transfer, peer discovery, authentication, and persistent transfer history are not implemented yet.
