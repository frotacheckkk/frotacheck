# FrotaCheck CI/CD Build Configuration

## Overview
This file contains build configurations and automation scripts for FrotaCheck Flutter application.

## Build Profiles

### Development Build
```bash
flutter build apk --debug
flutter build web --debug
```

### Release Build
```bash
flutter build apk --release
flutter build web --release
flutter build ios --release
```

## Testing Strategy

### Unit Tests
- Model validation tests
- Business logic tests
- Data transformation tests

### Widget Tests
- Widget rendering tests
- User interaction tests
- Navigation tests

### Integration Tests
- End-to-end user flows
- Backend integration
- Real device testing

## Build Artifacts

### Android
- Location: `build/app/outputs/flutter-apk/`
- Format: APK or App Bundle

### iOS
- Location: `build/ios/Release-iphoneos/`
- Format: IPA (requires signing)

### Web
- Location: `build/web/`
- Format: HTML/JS/CSS

### Windows
- Location: `build/windows/runner/Release/`
- Format: EXE

## GitHub Actions Workflow

The `.github/workflows/flutter-ci-cd.yml` file implements:
1. **Analyze & Test**: Code analysis and unit tests
2. **Build Web**: Web release build
3. **Build APK**: Android release build
4. **Build iOS**: iOS release build (no codesign)
5. **Build Windows**: Windows release build

## Deployment Steps

### Local Build & Test
```bash
# Run analyzer
flutter analyze

# Run tests
flutter test --coverage

# Build for target platform
flutter build apk --release   # Android
flutter build web --release   # Web
flutter build ios --release   # iOS (macOS only)
flutter build windows --release  # Windows
```

### CI/CD Pipeline
Triggered automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

Builds are validated through:
1. Static analysis (flutter analyze)
2. Unit tests (flutter test)
3. Platform-specific builds
4. Artifact upload to GitHub Actions

## Environment Requirements

### Host Requirements
- Flutter SDK: Latest stable
- Dart: ^3.11.0
- Java: For Android builds (JDK 11+)
- Xcode: For iOS builds (macOS only)
- Visual Studio Build Tools: For Windows builds

### CI/CD Requirements
- GitHub Actions runner (ubuntu-latest for Android/Web, macos-latest for iOS, windows-latest for Windows)
- Sufficient disk space (3GB+ per build)
- Build timeouts: 30-60 minutes per platform

## Build Configuration Files

- `pubspec.yaml`: Dependency management
- `analysis_options.yaml`: Lint rules
- `android/build.gradle.kts`: Android build config
- `ios/Podfile`: iOS dependencies
- `web/index.html`: Web entry point
- `windows/CMakeLists.txt`: Windows build config
