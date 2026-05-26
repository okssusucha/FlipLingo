<p align="center">
  <img src="AppIcon_v6.png" width="128" height="128" alt="FlipLingo">
</p>

<h1 align="center">FlipLingo</h1>

<p align="center">
  <a href="README.md">English</a> ·
  <a href="README.ja.md">日本語</a> ·
  <b>한국어</b>
</p>

<p align="center">
  <b>Mac 메뉴 막대에서 즉시 다국어 번역</b><br>
  텍스트 선택 → 단축키 누르기 → 즉시 번역
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2013%2B-blue" alt="macOS 13+">
  <img src="https://img.shields.io/badge/swift-5.9-orange" alt="Swift 5.9">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="MIT License">
  <img src="https://img.shields.io/badge/translation-DeepL%20API-0F2B46" alt="DeepL">
</p>

---

## 기능

- **즉시 교체** — 텍스트를 선택하고 `⌘⇧T`를 누르면 번역 결과로 교체됩니다
- **미리보기 모드** — `⌘⇧Y`로 적용 전에 번역 결과를 미리 확인
- **12개 언어 지원** — 일본어, 한국어, 영어, 중국어, 독일어, 프랑스어, 스페인어, 포르투갈어, 이탈리아어, 네덜란드어, 폴란드어, 러시아어
- **원본 언어 자동 감지** — DeepL이 원문 언어를 자동으로 판별
- **교체와 미리보기에 각각 다른 번역 대상** — 교체 모드와 미리보기 모드에 서로 다른 언어 설정 가능
- **어디서나 동작** — 네이티브 앱(텍스트 편집기, 메모)은 Accessibility API, Electron 앱(Slack, Chrome)은 클립보드 폴백으로 지원
- **단축키 커스터마이징** — 설정에서 단축키 변경 가능
- **메뉴 막대 앱** — 애니메이션 팩맨 아이콘이 메뉴 막대에 상주
- **4개의 UI 언어** — 일본어, 한국어, 영어, 중국어

## 설치

### DMG로 설치 (권장)

1. [Releases](../../releases)에서 `FlipLingo.dmg` 다운로드
2. `FlipLingo.app`을 응용 프로그램 폴더로 드래그
3. 첫 실행 시: 우클릭 → 열기 (Gatekeeper 우회)

### 소스에서 빌드

```bash
git clone https://github.com/YOUR_USERNAME/FlipLingo.git
cd FlipLingo
swift build
```

빌드된 바이너리를 앱 번들로 복사합니다:

```bash
mkdir -p FlipLingo.app/Contents/MacOS
mkdir -p FlipLingo.app/Contents/Resources
cp .build/arm64-apple-macosx/debug/FlipLingo FlipLingo.app/Contents/MacOS/
cp Info.plist FlipLingo.app/Contents/
```

## 설정

1. **DeepL API 키** — [deepl.com/pro-api](https://www.deepl.com/pro-api)에서 무료 키 발급 (월 50만 자 무료)
2. **손쉬운 사용 권한** — 시스템 설정 > 개인 정보 보호 및 보안 > 손쉬운 사용 → FlipLingo 활성화
3. 메뉴 막대 아이콘 클릭 → 설정 → API 키 입력

## 사용법

| 단축키 | 동작 |
|----------|--------|
| `⌘⇧T` | 선택한 텍스트를 번역하여 교체 |
| `⌘⇧Y` | 번역 미리보기 (읽기 전용 팝업) |

### 설정

- **번역 대상 언어** — 교체 단축키용 언어
- **미리보기 번역 대상 언어** — 미리보기 단축키용 언어 (다른 언어 지정 가능)
- **교체 시 미리보기** — `⌘⇧T`에서도 확인 팝업 표시
- **앱 언어** — UI를 日本語 / 한국어 / English / 中文로 전환

## 아키텍처

```
Sources/
├── main.swift               # 진입점, 메뉴 막대, AppDelegate
├── HotkeyManager.swift      # Carbon 전역 단축키 (⌘⇧T, ⌘⇧Y)
├── ClipboardManager.swift   # AXUIElement + osascript 폴백
├── TranslationService.swift # DeepL API, 12개 언어
├── TranslationPopup.swift   # 미리보기 팝업 UI
├── SettingsView.swift       # 설정 (카드 기반 UI)
├── ShortcutRecorderView.swift # 단축키 레코더
└── Localization.swift       # 4개의 UI 언어 (ja/ko/en/zh)
```

## 요구 사항

- macOS 13.0 이상
- Swift 5.9 이상
- DeepL API Free 키

## 라이선스

MIT
