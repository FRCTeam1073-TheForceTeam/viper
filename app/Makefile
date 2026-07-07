.PHONY: linux
linux: build
	flutter run -d linux

.PHONY: build
build:
	flutter analyze
	dart run build_runner build

.PHONY: fresh
fresh:
	rm -rf ~/.local/share/com.example.viper_scout/ ~/.cache/com.example.viper_scout/ ~/.snap/data/code/*/.local/share/com.example.viper_scout/
