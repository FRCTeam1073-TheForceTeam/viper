ifeq ($(OS),Windows_NT)
	CURRENT_PLATFORM := windows
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		CURRENT_PLATFORM := linux
	endif
	ifeq ($(UNAME_S),Darwin)
		CURRENT_PLATFORM := macos
	endif
endif

.PHONY: run
run: run-$(CURRENT_PLATFORM)

.PHONY: run-android
run-android: .analyze android
	flutter run -d android

.PHONY: run-ios
run-ios: .analyze ios
	flutter run -d ios

.PHONY: run-macos
run-macos: .analyze macos
	flutter run -d macos

.PHONY: run-linux
run-linux: .analyze linux
	flutter run -d linux

.PHONY: run-windows
run-windows: .analyze windows
	flutter run -d windows

.PHONY: build-android
build-android: build/app/outputs/flutter-apk/app-release.apk

build/app/outputs/flutter-apk/app-release.apk: .analyze android
	flutter build apk

.PHONY: build-ios
build-ios: .analyze ios
	flutter build ipa

.build-runner: pubspec.yaml $(shell find lib/data/database -name '*.dart' ! -name '*.g.dart')
	dart run build_runner build
	@touch .build-runner

.analyze: .build-runner pubspec.yaml $(shell find lib -name '*.dart' ! -name '*.g.dart')
	flutter analyze
	@touch .analyze

android:
	flutter create --platforms=android .
	@touch android

ios:
	flutter create --platforms=ios .
	@touch ios

macos:
	flutter create --platforms=macos .
	@touch macos

linux:
	flutter create --platforms=linux .
	@touch linux

windows:
	flutter create --platforms=windows .
	@touch windows

.PHONY: clean
clean:
	rm -rf build/ .dart_tool/ .analyze .build-runner .idea/ .flutter-plugins-dependencies *.iml android/ ios/ macos/ linux/ windows/ lib/data/database/*.g.dart

.PHONY: fresh
fresh:
	rm -rf ~/.local/share/com.example.viper_scout/ ~/.cache/com.example.viper_scout/ ~/.snap/data/code/*/.local/share/com.example.viper_scout/

.PHONY: test
test:
	flutter test
