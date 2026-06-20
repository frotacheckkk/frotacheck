# FrotaCheck - Fleet Management System

A modern, feature-rich Flutter application for comprehensive fleet management including vehicle tracking, fuel management, maintenance scheduling, driver management, and detailed reporting.

**Latest Update:** 2026-06-17  
**Status:** ✅ Production Ready  
**Flutter:** 3.11+  
**Dart:** 3.11.0+

## Features

✅ **Fleet Management**
- Vehicle registration and tracking
- Real-time vehicle status monitoring
- Maintenance scheduling and history
- Fuel consumption tracking

✅ **Driver Management**
- Driver registration and CNH tracking
- Driver performance monitoring
- Work schedule management

✅ **Operations**
- Trip planning and tracking
- Incident/problem reporting
- Document management
- Safety checklists (departure/return)

✅ **Analytics**
- Fuel consumption reports
- Maintenance analytics
- Trip history and statistics
- Cost tracking

✅ **Security**
- Supabase authentication
- Role-based access control (RBAC)
- Biometric support (passkeys)

## Quick Start

### Prerequisites
- Flutter SDK (latest stable)
- Dart 3.11.0+
- Git

### Setup
```bash
# Clone the repository
git clone <repository-url>
cd frotacheck

# Get dependencies
flutter pub get

# Configure Supabase
# Update lib/core/config/supabase_config.dart with your credentials
```

### Imagens do app (logo e avatar)

Coloque imagens em `assets/images/` e confirme que `pubspec.yaml` lista `assets/images/` em `flutter.assets:` (já está configurado).

- `assets/images/logo_shield.png` — será usado no topo da sidebar quando presente.
- `assets/images/avatar_fernando.png` — será exibido no card de perfil no rodapé da sidebar quando presente.

Se as imagens não estiverem presentes, o app usa ícones ou iniciais como fallback.

### Running the App

**Development (Web)**
```bash
flutter run -d chrome
```

**Development (Mobile)**
```bash
flutter devices                  # List available devices
flutter run -d <device-id>
```

**Release Mode**
```bash
flutter run --release
```

## Building for Different Platforms

### Using Make (Recommended)
```bash
make build-web      # Web release
make build-apk      # Android APK
make build-ios      # iOS (macOS only)
make build-windows  # Windows
make build-all      # All platforms

make help           # Show all available commands
```

### Manual Build Commands

**Web Release**
```bash
flutter build web --release
# Output: build/web/
```

**Android APK**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/
```

**Android App Bundle (Play Store)**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/
```

**iOS (macOS only)**
```bash
flutter build ios --release --no-codesign
# Output: build/ios/Release-iphoneos/
```

**Windows**
```bash
flutter build windows --release
# Output: build/windows/runner/Release/
```

## Testing & Quality Assurance

### Run Tests
```bash
# All tests with coverage
flutter test --coverage

# Specific test file
flutter test test/unit/models/multa_model_test.dart

# Tests matching pattern
flutter test --name "Multa"
```

### Code Analysis
```bash
# Check code quality
flutter analyze

# Format code
dart format lib/ --fix

# Auto-fix issues
dart fix --apply lib/
```

### Quality Checks
```bash
# Run all checks (analyze + test)
make check
```

## Continuous Integration

### GitHub Actions Workflow
Automated pipeline triggered on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

**Jobs:**
1. Code analysis and unit tests
2. Web build
3. Android APK build
4. iOS build
5. Windows build

Artifacts are automatically uploaded to GitHub Actions.

## Documentation

- **[Setup & Build Guide](SETUP_BUILD_GUIDE.md)** - Complete setup and build instructions
- **[Build Configuration](BUILD_CONFIG.md)** - Build profiles and deployment guide
- **[Implementation Report](IMPLEMENTATION_REPORT.md)** - Full implementation summary

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── config/                  # Supabase configuration
│   └── theme/                   # App theming
├── features/
│   ├── auth/                    # Authentication
│   └── home_page.dart          # Dashboard
├── home/
│   ├── abastecimentos/         # Fuel management
│   ├── checklists/             # Safety checklists
│   ├── documentos/             # Document management
│   ├── manutencoes/            # Maintenance
│   ├── motoristas/             # Driver management
│   ├── multas/                 # Fine management
│   ├── relatorios/             # Reports
│   ├── timeline/               # Event timeline
│   ├── veiculos/               # Vehicle management
│   └── viagens/                # Trip management
├── pages/                       # Additional pages
└── shared/
    ├── models/                  # Data models
    ├── widgets/                 # Reusable widgets
    └── services/                # Business logic

test/
├── shared_widgets_menu_card_test.dart
└── unit/
    └── models/
        ├── multa_model_test.dart
        ├── viagem_model_test.dart
        ├── veiculo_model_test.dart
        └── motorista_model_test.dart

.github/workflows/
└── flutter-ci-cd.yml           # CI/CD pipeline

Makefile                         # Build automation
BUILD_CONFIG.md                  # Build guide
SETUP_BUILD_GUIDE.md            # Setup guide
IMPLEMENTATION_REPORT.md        # Implementation report
```

## Configuration

### Supabase Setup
Update `lib/core/config/supabase_config.dart`:
```dart
const String supabaseUrl = 'YOUR_SUPABASE_URL';
const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

### Version Management
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Format: semantic-version+build-number
```

## Dependencies

### Core
- `supabase_flutter: ^2.15.0` - Backend & authentication
- `flutter: stable` - Flutter SDK
- `cupertino_icons: ^1.0.8` - iOS icons

### UI
- `fl_chart: ^0.68.0` - Charts and graphs

### Utilities
- `image_picker: ^1.1.2` - Image selection
- `file_picker: ^5.5.0` - File selection
- `path: ^1.9.0` - Path handling
- `passkeys: ^2.20.0` - Biometric authentication
- `device_info_plus: ^13.1.0` - Device information
- `package_info_plus: ^9.0.1` - Package information

See `pubspec.yaml` for complete dependency list.

## Troubleshooting

### Common Issues

**"Flutter SDK not found"**
```bash
flutter doctor
# Follow instructions to set up Flutter
```

**"Pod install failed" (iOS)**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

**"Gradle build failed" (Android)**
```bash
flutter clean
rm -rf android/.gradle
flutter pub get
flutter build apk --debug
```

**"Build hangs during web compilation"**
```bash
export DART_DEFINES=ENVIRONMENT=dev
flutter build web --web-renderer html
```

For more troubleshooting, see [Setup & Build Guide](SETUP_BUILD_GUIDE.md#troubleshooting).

## Deployment

### Web Hosting
- **GitHub Pages**: Deploy `build/web/` contents
- **Netlify**: Connect repo, build command: `flutter build web`
- **Vercel**: Deploy `build/web/` as static site
- **Firebase Hosting**: Deploy `build/web/` contents

### Mobile App Stores
- **Google Play Store**: Upload APK/AAB from `build/app/outputs/`
- **Apple App Store**: Requires Xcode signing and provisioning profiles
- **Alternative**: Custom enterprise distribution

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-06-17 | Initial release, Flutter 3.11+, Supabase 2.15.0 |

## Performance Metrics

- ✅ Code Analysis: Clean (no issues)
- ✅ Test Coverage: Comprehensive unit tests
- ✅ Build Time: ~5-30 minutes (platform dependent)
- ✅ App Size: ~50-150 MB (platform dependent)

## License

[Add your license here]

## Support & Contact

For support or questions:
- 📧 Email: [your-email@example.com]
- 🐛 Issues: GitHub Issues
- 📖 Docs: See documentation folder

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Supabase Documentation](https://supabase.com/docs)
- [GitHub Actions](https://docs.github.com/en/actions)

---

**Last Updated:** 2026-06-17  
**Maintained By:** Development Team  
**Status:** ✅ Production Ready

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
