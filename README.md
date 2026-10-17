# iPhone Starter — native SwiftUI + cloud IPA build

This is a starter iPhone app project, not the finished app idea yet. It provides a dark native SwiftUI screen, standard iOS navigation, SF Symbols, and a small Liquid Glass demonstration. Replace the sample home screen with the feature set you decide on.

## Liquid Glass

The project targets iOS 26.0 and uses APIs from the iOS 26 SDK. Standard SwiftUI navigation and controls can adopt Apple's platform appearance; the custom card uses a glass effect explicitly. The actual rendering depends on the iOS version and system settings.

## Create an IPA from Windows using GitHub Actions

The workflow `.github/workflows/build-ipa.yml` builds the app on a GitHub-hosted macOS runner. You do not need Xcode installed on your Windows PC.

1. Extract this project into a folder, for example `E:\Documents\iPhoneStarter`.
2. Create a GitHub repository for the project. A public repository is the simplest way to avoid GitHub Actions usage charges, subject to GitHub's current terms. Do not upload secrets or personal signing certificates into the repository.
3. From PowerShell in the extracted project folder, configure and push the repository (replace the URL with your own repository URL):

   ```powershell
   git init
   git add .
   git commit -m "Create native iPhone starter app"
   git branch -M main
   git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git
   git push -u origin main
   ```

4. On GitHub, open the repository's **Actions** tab and select **Build iPhone Starter IPA**. Use **Run workflow** if a build has not already started after the push.
5. When the run finishes, open it and download the artifact named `iPhoneStarter-unsigned-IPA`. Extract the ZIP artifact to find `iPhoneStarter-unsigned.ipa`.
6. Give that IPA to your existing sideloading/signing tool. This workflow deliberately creates an **unsigned IPA package** because no Apple signing credentials have been provided. The installer must be able to sign/re-sign an unsigned IPA. If it cannot, the project will need the appropriate Apple signing credentials and provisioning profile instead.

## PowerShell commands are not run automatically

The commands above create Git metadata and upload these project files to the GitHub repository you specify. They do not install anything on the iPhone or modify your Windows settings. Review the repository visibility before pushing.

## Project details

- App display name: `iPhone Starter`
- Bundle identifier: `com.therealraphael.iphonestarter`
- Deployment target: iOS 26.0 or newer
- Framework: SwiftUI (native iOS UI)
- Build workflow: GitHub Actions / macOS 26 runner
- Output: `iPhoneStarter-unsigned.ipa`

The IPA has not been built in this Windows environment; GitHub Actions must run the cloud workflow to produce it.
