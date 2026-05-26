import Foundation

enum AppLanguage: String, CaseIterable {
    case ja = "ja"
    case ko = "ko"
    case en = "en"
    case zh = "zh"

    var displayName: String {
        switch self {
        case .ja: return "日本語"
        case .ko: return "한국어"
        case .en: return "English"
        case .zh: return "中文"
        }
    }
}

struct L {
    static var current: AppLanguage {
        let raw = UserDefaults.standard.string(forKey: "app_language") ?? "ja"
        return AppLanguage(rawValue: raw) ?? .ja
    }

    private static func t(_ ja: String, _ ko: String, _ en: String, _ zh: String) -> String {
        switch current {
        case .ja: return ja
        case .ko: return ko
        case .en: return en
        case .zh: return zh
        }
    }

    static var shortcutKey: String { HotkeyManager.shared.shortcutDisplayString }
    static var previewKey: String { HotkeyManager.shared.previewShortcutDisplayString }

    // Menu
    static var menuTranslate: String {
        t("翻訳して置換 (\(shortcutKey))", "번역 후 교체 (\(shortcutKey))",
          "Translate & Replace (\(shortcutKey))", "翻译并替换 (\(shortcutKey))")
    }
    static var menuPreview: String {
        t("翻訳プレビュー (\(previewKey))", "번역 미리보기 (\(previewKey))",
          "Translation Preview (\(previewKey))", "翻译预览 (\(previewKey))")
    }
    static var menuSettings: String { t("設定...", "설정...", "Settings...", "设置...") }
    static var menuQuit: String { t("終了", "종료", "Quit", "退出") }
    static var menuBarTooltip: String { "FlipLingo (\(shortcutKey))" }

    // Settings
    static var settingsTitle: String {
        t("FlipLingo 設定", "FlipLingo 설정", "FlipLingo Settings", "FlipLingo 设置")
    }
    static var settingsSubtitle: String {
        t("多言語 AI翻訳ツール", "다국어 AI 번역 도구", "Multilingual AI Translation Tool", "多语言 AI 翻译工具")
    }
    static var apiKeySection: String { t("DeepL API キー", "DeepL API 키", "DeepL API Key", "DeepL API 密钥") }
    static var apiKeyPlaceholder: String {
        t("DeepL API キーを入力", "DeepL API 키를 입력", "Enter DeepL API Key", "输入 DeepL API 密钥")
    }
    static var apiKeyHelp: String {
        t("DeepL API Free のキーを取得: https://www.deepl.com/pro-api",
          "DeepL API Free 키 발급: https://www.deepl.com/pro-api",
          "Get DeepL API Free key: https://www.deepl.com/pro-api",
          "获取 DeepL API Free 密钥: https://www.deepl.com/pro-api")
    }
    static var apiTest: String { t("APIテスト", "API 테스트", "Test API", "测试 API") }
    static var apiTestSuccess: String { t("成功", "성공", "Success", "成功") }
    static var pasteFromClipboard: String {
        t("クリップボードから貼り付け", "클립보드에서 붙여넣기", "Paste from clipboard", "从剪贴板粘贴")
    }

    static var targetLangSection: String {
        t("翻訳先の言語", "번역 대상 언어", "Target Language", "目标语言")
    }
    static var targetLangHelp: String {
        t("置換時の翻訳先言語。ソース言語はDeepLが自動検出します。",
          "교체 시 번역 대상 언어. 소스 언어는 DeepL이 자동 감지합니다.",
          "Target language for replacement. Source language is auto-detected by DeepL.",
          "替换时的目标语言。源语言由 DeepL 自动检测。")
    }
    static var previewTargetLangSection: String {
        t("プレビュー用翻訳先言語", "미리보기용 번역 대상 언어", "Preview Target Language", "预览目标语言")
    }
    static var previewTargetLangHelp: String {
        t("プレビュー時の翻訳先言語。置換とは別の言語を指定できます。",
          "미리보기 시 번역 대상 언어. 교체와 다른 언어를 지정할 수 있습니다.",
          "Target language for preview. Can differ from replacement language.",
          "预览时的目标语言。可以与替换语言不同。")
    }

    static var shortcutSection: String { t("ショートカット", "단축키", "Shortcuts", "快捷键") }
    static var shortcutReplace: String { t("翻訳して置換:", "번역 후 교체:", "Translate & Replace:", "翻译并替换:") }
    static var shortcutPreview: String { t("翻訳プレビュー:", "번역 미리보기:", "Translation Preview:", "翻译预览:") }
    static var shortcutHelp: String {
        t("クリックしてからキーを押すと変更できます。",
          "클릭 후 키를 누르면 변경할 수 있습니다.",
          "Click then press keys to change the shortcut.",
          "点击后按键即可更改快捷键。")
    }

    static var behaviorSection: String { t("翻訳動作", "번역 동작", "Behavior", "翻译行为") }
    static var previewToggle: String {
        t("置換時にプレビュー表示", "교체 시 미리보기 표시", "Show preview on replace", "替换时显示预览")
    }
    static var previewOnHelp: String {
        t("置換ショートカットでもプレビューを表示します。",
          "교체 단축키에서도 미리보기를 표시합니다.",
          "Shows preview popup even with the replace shortcut.",
          "替换快捷键也会显示预览弹窗。")
    }
    static var previewOffHelp: String {
        t("置換ショートカットで即座にテキストを置換します。",
          "교체 단축키로 즉시 텍스트를 교체합니다.",
          "Immediately replaces text with the replace shortcut.",
          "替换快捷键会立即替换文本。")
    }

    static var languageSection: String { t("アプリ言語", "앱 언어", "App Language", "应用语言") }
    static var languageHelp: String {
        t("UIの表示言語を変更します。", "UI 표시 언어를 변경합니다.",
          "Change the app UI language.", "更改应用界面语言。")
    }

    static var usageSection: String { t("使い方", "사용법", "How to Use", "使用方法") }
    static var usage1: String {
        t("翻訳したいテキストを選択", "번역할 텍스트를 선택",
          "Select text to translate", "选择要翻译的文本")
    }
    static var usage2: String {
        t("\(shortcutKey) で翻訳して置換", "\(shortcutKey)로 번역 후 교체",
          "\(shortcutKey) to translate & replace", "\(shortcutKey) 翻译并替换")
    }
    static var usage3: String {
        t("\(previewKey) で翻訳プレビュー（読み取り専用）",
          "\(previewKey)로 번역 미리보기 (읽기 전용)",
          "\(previewKey) for translation preview (read-only)",
          "\(previewKey) 翻译预览（只读）")
    }
    static var usage4: String {
        t("プレビューでは「適用」「コピー」が選択可能",
          "미리보기에서 \"적용\" \"복사\" 선택 가능",
          "In preview, you can Apply or Copy",
          "预览中可以选择「应用」或「复制」")
    }

    static var accessibilitySection: String { t("アクセシビリティ", "접근성", "Accessibility", "辅助功能") }
    static var accessibilityNote: String {
        t("このアプリはアクセシビリティ権限が必要です。",
          "이 앱은 접근성 권한이 필요합니다.",
          "This app requires Accessibility permission.",
          "此应用需要辅助功能权限。")
    }
    static var accessibilityDetail: String {
        t("システム設定 > プライバシーとセキュリティ > アクセシビリティ で許可してください。",
          "시스템 설정 > 개인정보 보호 및 보안 > 접근성 에서 허용해주세요.",
          "Enable in System Settings > Privacy & Security > Accessibility.",
          "请在系统设置 > 隐私与安全 > 辅助功能中启用。")
    }
    static var openAccessibility: String {
        t("アクセシビリティ設定を開く", "접근성 설정 열기", "Open Accessibility Settings", "打开辅助功能设置")
    }

    // Popup
    static var originalText: String { t("原文", "원문", "Original", "原文") }
    static var translatedText: String { t("翻訳結果", "번역 결과", "Translation", "翻译结果") }
    static var apply: String { t("適用", "적용", "Apply", "应用") }
    static var copy: String { t("コピー", "복사", "Copy", "复制") }
    static var cancel: String { t("キャンセル", "취소", "Cancel", "取消") }

    // Errors
    static var noTextSelected: String {
        t("テキストが選択されていません。", "텍스트가 선택되지 않았습니다.",
          "No text selected.", "未选择文本。")
    }
    static var translationError: String { t("翻訳エラー", "번역 오류", "Translation Error", "翻译错误") }
    static var shortcutRecordPrompt: String {
        t("キーを押してください...", "키를 눌러주세요...", "Press keys...", "请按键...")
    }
}
