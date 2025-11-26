Development notes — uni_links temporary fix

If you get a Gradle error about `Namespace not specified` for `uni_links`, run the provided PowerShell script to create a local patched copy and use it via `dependency_overrides`.

Steps:
1. From project root run:

```powershell
cd Frontend\vetproapp
PowerShell -ExecutionPolicy Bypass -File .\tools\fix_uni_links.ps1
```

2. Then rebuild the app:

```powershell
flutter clean
flutter pub get
flutter run
```

This creates `plugins/uni_links` with `android/build.gradle` patched to include a namespace and updates `pubspec.yaml` (already configured) to use the local plugin.

This is a development workaround. For a permanent fix, either:
- Use a patched fork of `uni_links` and reference it via `git:` in `pubspec.yaml`, or
- Wait for the upstream plugin to publish a version compatible with your AGP.
