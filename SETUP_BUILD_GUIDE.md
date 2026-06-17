# FrotaCheck - Setup & Build Guide

## Project Overview
FrotaCheck is a comprehensive Flutter application for fleet management, including vehicle tracking, fuel management, maintenance scheduling, and incident reporting.

**Version:** 1.0.0  
**Flutter:** 3.11+  
**Dart:** 3.11.0+  
**Latest Update:** 2026-06-17

---

## Quick Start

### 1. Environment Setup

#### Required Tools
- Flutter SDK (latest stable)
- Dart SDK (^3.11.0)
- Git
- Your preferred IDE (VS Code, Android Studio, or Xcode)

#### Platform-Specific Requirements

**Android:**
- Java Development Kit (JDK 11+)
- Android SDK API 23+
- Android NDK (for native plugins)

**iOS:**
- macOS 12.0+
- Xcode 14+
- CocoaPods

**Web:**
- Chrome/Firefox for testing
- None (uses Dart-to-JS compilation)

**Windows:**
- Visual Studio 2022+ or Build Tools
- CMake 3.10+

### 2. Project Setup

```bash
# Clone repository
git clone <repository-url>
cd frotacheck

# Get dependencies
flutter pub get

# Verify environment
flutter doctor -v
```

### 3. Running the App

#### Development Mode
```bash
# Run on default device
flutter run

# Run on specific device
flutter devices                    # List available devices
flutter run -d <device-id>

# Run on web
flutter run -d chrome

# Run on web with hot restart
flutter run -d web-server
```

#### Release Mode
```bash
flutter run --release
```

---

## Building for Different Platforms

### Android (APK)

#### Debug Build
```bash
flutter build apk --debug
```

#### Release Build
```bash
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

#### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

**Output:** `build/app/outputs/bundle/release/app-release.aab`

### iOS

#### Requirements
- macOS system
- Xcode installed
- Apple Developer account (for App Store)

#### Build
```bash
flutter build ios --release --no-codesign
```

**Output:** `build/ios/Release-iphoneos/`

#### Signing & Deployment
```bash
# Open in Xcode for signing
open ios/Runner.xcworkspace

# Or use command line
flutter build ipa --release
```

### Web

#### Development
```bash
flutter run -d chrome
```

#### Production Build
```bash
flutter build web --release
```

**Output:** `build/web/`  
**Deployment:** Upload contents of `build/web/` to any static hosting (Firebase, Netlify, Vercel, etc.)

### Windows

```bash
flutter build windows --release
```

**Output:** `build/windows/runner/Release/`

### macOS

```bash
flutter build macos --release
```

**Output:** `build/macos/Build/Products/Release/FrotaCheck.app`

### Linux

```bash
flutter build linux --release
```

**Output:** `build/linux/x64/release/bundle/`

---

## Quality Assurance

### Static Analysis
```bash
# Run Dart analyzer
flutter analyze

# With stricter linting
flutter analyze --no-pub
```

### Code Formatting
```bash
# Format all Dart files
dart format lib/ --fix

# Check formatting without applying
dart format lib/ --output none --set-exit-if-changed
```

### Fix Issues Automatically
```bash
dart fix --apply lib/
```

### Running Tests

#### Unit Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/models/multa_model_test.dart

# Run tests matching pattern
flutter test --name "Multa"
```

#### Widget Tests
```bash
flutter test test/widget/
```

#### Integration Tests
```bash
flutter test integration_test/
```

#### Generate Coverage Report
```bash
flutter test --coverage
# Coverage report: coverage/lcov.info
```

---

## Using Make Commands (Recommended)

All common tasks can be run via Makefile:

```bash
# Show all available commands
make help

# Setup
make pub-get
make pub-upgrade

# Quality checks
make analyze
make test
make check            # Analyze + test

# Building
make build-web        # Web release
make build-apk        # Android APK release
make build-ios        # iOS release
make build-windows    # Windows release
make build-all        # All platforms

# Development
make dev-web          # Web debug
make dev-apk          # Android debug
make run              # Run app

# Utilities
make format           # Format code
make fix              # Auto-fix issues
make clean            # Clean builds
make doctor           # Flutter doctor
```

---

## Dependency Management

### View Outdated Packages
```bash
flutter pub outdated
```

### Upgrade Dependencies
```bash
# Upgrade compatible versions only
flutter pub upgrade

# Upgrade including major versions
flutter pub upgrade --major-versions
```

### Add New Package
```bash
flutter pub add package_name
```

### Remove Package
```bash
flutter pub remove package_name
```

### Lock Dependencies
```bash
flutter pub get
# This updates pubspec.lock
```

---

## CI/CD Pipeline

### GitHub Actions Workflow
Configured in `.github/workflows/flutter-ci-cd.yml`

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

**Jobs:**
1. **Analyze & Test** (Ubuntu): Code analysis and unit tests
2. **Build Web** (Ubuntu): Web release build
3. **Build APK** (Ubuntu): Android release build
4. **Build iOS** (macOS): iOS release build
5. **Build Windows** (Windows): Windows release build

**Artifacts Generated:**
- `flutter-web-build`: Web application
- `flutter-apk-build`: Android APK
- `flutter-ios-build`: iOS build
- `flutter-windows-build`: Windows executable
- Coverage reports (codecov)

---

## Environment Variables & Configuration

### Supabase Configuration
Update in `lib/core/config/supabase_config.dart`:
```dart
const String supabaseUrl = 'YOUR_SUPABASE_URL';
const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

### Build Number Management
Update `pubspec.yaml`:
```yaml
version: 1.0.0+1
```
- First part (1.0.0) = version string
- Second part (+1) = build number

For release builds:
```bash
flutter build apk --build-number=2 --build-name=1.0.1
```

---

## Troubleshooting

### Common Issues

#### "Flutter SDK not found"
```bash
flutter doctor
# Follow the instructions to set up Flutter
```

#### "Pod install failed" (iOS)
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
```

#### "Gradle build failed" (Android)
```bash
flutter clean
rm -rf android/.gradle
flutter pub get
flutter build apk --debug
```

#### "Build hangs during web compilation"
Increase time and use minimal build:
```bash
export DART_DEFINES=ENVIRONMENT=dev
flutter build web --web-renderer html
```

#### "Certificate required" (iOS)
For development/testing without code signing:
```bash
flutter build ios --release --no-codesign
```

---

## Release Checklist

### Pre-Release
- [ ] Update version in `pubspec.yaml`
- [ ] Run `flutter analyze` - no issues
- [ ] Run `flutter test` - all pass
- [ ] Update CHANGELOG.md
- [ ] Review all dependencies with `flutter pub outdated`
- [ ] Test on multiple devices/platforms

### Android Release
- [ ] Generate signed APK/AAB
- [ ] Test thoroughly on physical device
- [ ] Check all app permissions
- [ ] Verify internet connectivity
- [ ] Test on different Android versions

### iOS Release
- [ ] Generate signed IPA
- [ ] Test on physical iPhone/iPad
- [ ] Verify provisioning profiles
- [ ] Check app permissions
- [ ] Review App Store Connect configuration

### Web Release
- [ ] Build with `--release` flag
- [ ] Test in multiple browsers
- [ ] Check responsive design
- [ ] Verify API endpoints (production vs dev)
- [ ] Test on slow network

### Post-Release
- [ ] Create git tag: `git tag v1.0.0`
- [ ] Push tag: `git push origin v1.0.0`
- [ ] Notify team/users
- [ ] Monitor crash reports
- [ ] Document release notes

---

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**Last Updated:** 2026-06-17  
**Maintained By:** Development Team
