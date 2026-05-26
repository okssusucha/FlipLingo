<p align="center">
  <img src="AppIcon_v6.png" width="128" height="128" alt="FlipLingo">
</p>

<h1 align="center">FlipLingo</h1>

<p align="center">
  <b>English</b> ·
  <a href="README.ja.md">日本語</a> ·
  <a href="README.ko.md">한국어</a>
</p>

<p align="center">
  <b>Instant multilingual translation from your Mac menu bar</b><br>
  Select text → Press shortcut → Translated instantly
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2013%2B-blue" alt="macOS 13+">
  <img src="https://img.shields.io/badge/swift-5.9-orange" alt="Swift 5.9">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="MIT License">
  <img src="https://img.shields.io/badge/translation-DeepL%20API-0F2B46" alt="DeepL">
</p>

---

## Features

- **Instant Replace** — Select text, press `⌘⇧T`, text is replaced with translation
- **Preview Mode** — Press `⌘⇧Y` to preview translation before applying
- **12 Languages** — Japanese, Korean, English, Chinese, German, French, Spanish, Portuguese, Italian, Dutch, Polish, Russian
- **Auto-detect Source** — DeepL automatically detects the source language
- **Separate Target Languages** — Set different languages for replace and preview modes
- **Works Everywhere** — Native apps (TextEdit, Notes) via Accessibility API, Electron apps (Slack, Chrome) via clipboard fallback
- **Customizable Shortcuts** — Change hotkeys in settings
- **Menu Bar App** — Animated Pac-Man icon lives in your menu bar
- **4 UI Languages** — Japanese, Korean, English, Chinese

## Install

### From DMG (Recommended)

1. Download `FlipLingo.dmg` from [Releases](../../releases)
2. Drag `FlipLingo.app` to Applications
3. First launch: Right-click → Open (bypass Gatekeeper)

### Build from Source

```bash
git clone https://github.com/YOUR_USERNAME/FlipLingo.git
cd FlipLingo
swift build
```

Copy the built binary into an app bundle:

```bash
mkdir -p FlipLingo.app/Contents/MacOS
mkdir -p FlipLingo.app/Contents/Resources
cp .build/arm64-apple-macosx/debug/FlipLingo FlipLingo.app/Contents/MacOS/
cp Info.plist FlipLingo.app/Contents/
```

## Setup

1. **DeepL API Key** — Get a free key at [deepl.com/pro-api](https://www.deepl.com/pro-api) (500K chars/month free)
2. **Accessibility Permission** — System Settings > Privacy & Security > Accessibility → Enable FlipLingo
3. Click the menu bar icon → Settings → Enter API key

## Usage

| Shortcut | Action |
|----------|--------|
| `⌘⇧T` | Translate and replace selected text |
| `⌘⇧Y` | Preview translation (read-only popup) |

### Settings

- **Target Language** — Language for the replace shortcut
- **Preview Target Language** — Language for the preview shortcut (can differ)
- **Preview on Replace** — Show confirmation popup even with `⌘⇧T`
- **App Language** — Switch UI between 日本語 / 한국어 / English / 中文

## Architecture

```
Sources/
├── main.swift               # Entry point, menu bar, AppDelegate
├── HotkeyManager.swift      # Carbon global hotkeys (⌘⇧T, ⌘⇧Y)
├── ClipboardManager.swift   # AXUIElement + osascript fallback
├── TranslationService.swift # DeepL API, 12 languages
├── TranslationPopup.swift   # Preview popup UI
├── SettingsView.swift       # Settings (card-based UI)
├── ShortcutRecorderView.swift # Shortcut recorder
└── Localization.swift       # 4 UI languages (ja/ko/en/zh)
```

## Requirements

- macOS 13.0+
- Swift 5.9+
- DeepL API Free key

## License

MIT
