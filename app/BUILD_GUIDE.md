# Flutter App Build & Run Guide

## Quick Start

### 1. Prerequisites
- Flutter 3.11.1+ and Dart 3.11.1+
- iOS: Xcode 14+, iOS SDK 12.0+
- Android: Android SDK API 21+

### 2. Install Dependencies
```bash
cd /home/steveo/sites/viper/frc-app
flutter pub get
```

### 3. Generate Database Code (IMPORTANT!)
The Drift database requires code generation:
```bash
flutter pub run build_runner build
```

If you get errors, clean and try again:
```bash
flutter pub run build_runner clean
flutter pub run build_runner build
```

### 4. Run the App

**iOS Simulator:**
```bash
flutter run -d "iPhone 15"
```

**Android Emulator:**
```bash
flutter run -d emulator-5554
```

**Physical Device:**
```bash
flutter run
```

### 5. Build for Production

**iOS:**
```bash
flutter build ios --release
# Then use Xcode to archive and upload to App Store
```

**Android:**
```bash
flutter build apk --release
# APK will be at build/app/outputs/flutter-app/release/app-release.apk

# Or AAB for Play Store:
flutter build appbundle --release
```

## First Time Setup

1. **App launches → EventPickerScreen**
2. **Configure Backend URL:**
   - Tap Settings (gear icon)
   - Enter backend URL (e.g., `http://192.168.1.100`)
   - Tap "Test Connection"
   - Save
3. **Select Event:**
   - List shows events from current season
   - Tap to select
4. **Start Scouting:**
   - Fill in Match & Team
   - Navigate between 5 tabs
   - Fill in data
   - Tap Save on each tab
5. **Sync:**
   - When online, appears automatically
   - Status shown in AppBar
   - Manual sync: Settings → "Sync Now"

## Debugging

### View Logs
```bash
flutter logs
```

### Run in Debug Mode
```bash
flutter run
```

### Hot Reload
Press `r` in terminal while app is running

### Hot Restart
Press `R` in terminal to restart Dart VM

## Environment Variables

Create `.env` file (optional):
```
BACKEND_URL=http://viper.local
ENABLE_LOGGING=true
```

Note: Currently not used by app, but can be added to config_service.dart

## Common Issues

### Build Fails with "Drift" Errors
**Solution:** Regenerate code
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Can't find devices
```bash
flutter devices  # List available devices
flutter run -d all  # Run on all connected devices
```

### Database locked errors
**Solution:** Close other app instances, rebuild
```bash
flutter clean
flutter pub get
flutter pub run build_runner build
flutter run
```

## Performance Tips

1. Use release build for final testing (`flutter run --release`)
2. Profile performance: `flutter run --profile`
3. Enable sksl warmup for smooth startup
4. Test offline mode by disabling network in settings

## Next Steps

1. ✅ Basic app structure complete
2. 🔄 Ready for Drift code generation
3. 📱 Test on iOS/Android devices
4. 🌍 Add i18n (7 languages)
5. 🧪 Add unit/widget tests
6. 📦 Build for production
