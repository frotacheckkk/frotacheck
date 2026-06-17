.PHONY: help clean analyze test build-web build-apk build-ios build-windows build-all pub-get pub-upgrade

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

help:
	@echo "$(BLUE)FrotaCheck Flutter Build Commands$(NC)"
	@echo ""
	@echo "$(GREEN)Setup:$(NC)"
	@echo "  make pub-get          - Get all dependencies"
	@echo "  make pub-upgrade      - Upgrade to latest compatible versions"
	@echo ""
	@echo "$(GREEN)Analysis & Testing:$(NC)"
	@echo "  make analyze          - Run Dart analyzer"
	@echo "  make test             - Run all tests with coverage"
	@echo "  make clean            - Clean build artifacts"
	@echo ""
	@echo "$(GREEN)Build for Platform:$(NC)"
	@echo "  make build-web        - Build web release"
	@echo "  make build-apk        - Build Android APK release"
	@echo "  make build-ios        - Build iOS release (macOS only)"
	@echo "  make build-windows    - Build Windows release"
	@echo ""
	@echo "$(GREEN)Development:$(NC)"
	@echo "  make dev-web          - Build web debug"
	@echo "  make dev-apk          - Build Android APK debug"
	@echo ""
	@echo "$(GREEN)Utilities:$(NC)"
	@echo "  make build-all        - Build all platforms"
	@echo "  make check            - Analyze + test (CI mode)"

pub-get:
	@echo "$(YELLOW)Getting dependencies...$(NC)"
	flutter pub get

pub-upgrade:
	@echo "$(YELLOW)Upgrading dependencies...$(NC)"
	flutter pub upgrade

clean:
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	flutter clean
	rm -rf build/
	rm -rf coverage/

analyze:
	@echo "$(YELLOW)Running analyzer...$(NC)"
	flutter analyze

test:
	@echo "$(YELLOW)Running tests with coverage...$(NC)"
	flutter test --coverage
	@echo "$(GREEN)Coverage report generated at coverage/lcov.info$(NC)"

check: analyze test
	@echo "$(GREEN)✓ Code quality checks passed!$(NC)"

build-web:
	@echo "$(YELLOW)Building Web Release...$(NC)"
	flutter build web --release
	@echo "$(GREEN)✓ Web build complete: build/web/$(NC)"

build-apk:
	@echo "$(YELLOW)Building Android APK Release...$(NC)"
	flutter build apk --release
	@echo "$(GREEN)✓ APK build complete: build/app/outputs/flutter-apk/$(NC)"

build-ios:
	@echo "$(YELLOW)Building iOS Release (no codesign)...$(NC)"
	flutter build ios --release --no-codesign
	@echo "$(GREEN)✓ iOS build complete: build/ios/Release-iphoneos/$(NC)"

build-windows:
	@echo "$(YELLOW)Building Windows Release...$(NC)"
	flutter build windows --release
	@echo "$(GREEN)✓ Windows build complete: build/windows/runner/Release/$(NC)"

dev-web:
	@echo "$(YELLOW)Building Web Debug...$(NC)"
	flutter build web --debug

dev-apk:
	@echo "$(YELLOW)Building Android APK Debug...$(NC)"
	flutter build apk --debug

build-all: build-web build-apk
	@echo "$(GREEN)✓ All platform builds complete!$(NC)"

# Install development tools
install-tools:
	@echo "$(YELLOW)Installing development tools...$(NC)"
	flutter pub global activate coverage
	flutter pub global activate dart_code_metrics

# Format code
format:
	@echo "$(YELLOW)Formatting Dart code...$(NC)"
	dart format lib/ --fix

# Fix issues
fix:
	@echo "$(YELLOW)Fixing code issues...$(NC)"
	dart fix --apply lib/

# Run app (debug)
run:
	@echo "$(YELLOW)Running app...$(NC)"
	flutter run

# Run app on specific device
run-device:
	@echo "$(YELLOW)Available devices:$(NC)"
	flutter devices
	@echo "$(YELLOW)Use: flutter run -d <device-id>$(NC)"

# Doctor check
doctor:
	@echo "$(YELLOW)Running Flutter doctor...$(NC)"
	flutter doctor -v
