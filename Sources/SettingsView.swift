import SwiftUI
import AppKit

struct SettingsView: View {
    @AppStorage("deepl_api_key") private var apiKey: String = ""
    @AppStorage("preview_enabled") private var previewEnabled: Bool = true
    @AppStorage("app_language") private var appLanguage: String = "ja"
    @AppStorage("target_language") private var targetLanguage: String = "KO"
    @AppStorage("preview_target_language") private var previewTargetLanguage: String = "JA"
    @State private var testResult: String = ""
    @State private var isTesting: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                VStack(spacing: 16) {
                    apiKeyCard
                    targetLangCard
                    previewTargetLangCard
                    shortcutCard
                    behaviorCard
                    languageCard
                    usageCard
                    accessibilityCard
                }
                .padding(20)
            }
        }
        .frame(width: 500, height: 720)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var headerSection: some View {
        VStack(spacing: 6) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 36))
                .foregroundStyle(.linearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            Text("FlipLingo")
                .font(.title).fontWeight(.bold)
            Text(L.settingsSubtitle)
                .font(.subheadline).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(LinearGradient(
            colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.03)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        ))
    }

    private var apiKeyCard: some View {
        CardView(icon: "key.fill", iconColor: .orange, title: L.apiKeySection) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    TextField(L.apiKeyPlaceholder, text: $apiKey)
                        .textFieldStyle(.roundedBorder)
                    Button(action: {
                        if let clip = NSPasteboard.general.string(forType: .string) { apiKey = clip }
                    }) {
                        Image(systemName: "doc.on.clipboard").frame(width: 28, height: 28)
                    }
                    .help(L.pasteFromClipboard)
                }
                Link(L.apiKeyHelp, destination: URL(string: "https://www.deepl.com/pro-api")!)
                    .font(.caption)
                HStack(spacing: 8) {
                    Button(action: testApiKey) {
                        HStack(spacing: 4) {
                            if isTesting { ProgressView().scaleEffect(0.6) }
                            Text(L.apiTest)
                        }
                    }
                    .disabled(apiKey.isEmpty || isTesting)
                    if !testResult.isEmpty {
                        Text(testResult).font(.caption)
                            .foregroundColor(testResult.contains("✅") ? .green : .red)
                    }
                }
            }
        }
    }

    private var targetLangCard: some View {
        CardView(icon: "globe", iconColor: .blue, title: L.targetLangSection) {
            VStack(alignment: .leading, spacing: 8) {
                Picker("", selection: $targetLanguage) {
                    ForEach(SupportedLanguage.all) { lang in
                        Text(lang.name).tag(lang.code)
                    }
                }
                .labelsHidden()
                Text(L.targetLangHelp)
                    .font(.caption).foregroundColor(.secondary)
            }
        }
    }

    private var previewTargetLangCard: some View {
        CardView(icon: "eye.fill", iconColor: .purple, title: L.previewTargetLangSection) {
            VStack(alignment: .leading, spacing: 8) {
                Picker("", selection: $previewTargetLanguage) {
                    ForEach(SupportedLanguage.all) { lang in
                        Text(lang.name).tag(lang.code)
                    }
                }
                .labelsHidden()
                Text(L.previewTargetLangHelp)
                    .font(.caption).foregroundColor(.secondary)
            }
        }
    }

    private var shortcutCard: some View {
        CardView(icon: "keyboard.fill", iconColor: .blue, title: L.shortcutSection) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(L.shortcutReplace).foregroundColor(.secondary)
                    Spacer()
                    ShortcutRecorderView(
                        displayString: HotkeyManager.shared.shortcutDisplayString,
                        onRecord: { keyCode, mods in
                            let carbon = HotkeyManager.carbonModifiers(from: mods)
                            HotkeyManager.shared.hotkeyKeyCode = UInt32(keyCode)
                            HotkeyManager.shared.hotkeyModifiers = carbon
                            HotkeyManager.shared.register()
                        }
                    )
                }
                HStack {
                    Text(L.shortcutPreview).foregroundColor(.secondary)
                    Spacer()
                    ShortcutRecorderView(
                        displayString: HotkeyManager.shared.previewShortcutDisplayString,
                        onRecord: { keyCode, mods in
                            let carbon = HotkeyManager.carbonModifiers(from: mods)
                            HotkeyManager.shared.previewKeyCode = UInt32(keyCode)
                            HotkeyManager.shared.previewModifiers = carbon
                            HotkeyManager.shared.register()
                        }
                    )
                }
                Text(L.shortcutHelp).font(.caption).foregroundColor(.secondary)
            }
        }
    }

    private var behaviorCard: some View {
        CardView(icon: "gearshape.fill", iconColor: .gray, title: L.behaviorSection) {
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $previewEnabled) {
                    HStack { Text(L.previewToggle); Spacer() }
                }
                .toggleStyle(.switch)
                Text(previewEnabled ? L.previewOnHelp : L.previewOffHelp)
                    .font(.caption).foregroundColor(.secondary)
            }
        }
    }

    private var languageCard: some View {
        CardView(icon: "character.bubble.fill", iconColor: .green, title: L.languageSection) {
            VStack(alignment: .leading, spacing: 8) {
                Picker("", selection: $appLanguage) {
                    ForEach(AppLanguage.allCases, id: \.rawValue) { lang in
                        Text(lang.displayName).tag(lang.rawValue)
                    }
                }
                .pickerStyle(.segmented).labelsHidden()
                Text(L.languageHelp).font(.caption).foregroundColor(.secondary)
            }
        }
    }

    private var usageCard: some View {
        CardView(icon: "questionmark.circle.fill", iconColor: .purple, title: L.usageSection) {
            VStack(alignment: .leading, spacing: 8) {
                UsageRow(step: "1", text: L.usage1)
                UsageRow(step: "2", text: L.usage2)
                UsageRow(step: "3", text: L.usage3)
                UsageRow(step: "4", text: L.usage4)
            }
        }
    }

    private var accessibilityCard: some View {
        CardView(icon: "hand.raised.fill", iconColor: .red, title: L.accessibilitySection) {
            VStack(alignment: .leading, spacing: 8) {
                Text(L.accessibilityNote).font(.callout)
                Text(L.accessibilityDetail).font(.caption).foregroundColor(.secondary)
                Button(action: {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                }) {
                    HStack {
                        Image(systemName: "arrow.up.right.square")
                        Text(L.openAccessibility)
                    }.font(.callout)
                }
                .buttonStyle(.borderedProminent).controlSize(.small)
            }
        }
    }

    private func testApiKey() {
        isTesting = true; testResult = ""
        Task {
            do {
                let result = try await TranslationService.shared.translate("Hello", targetOverride: targetLanguage)
                await MainActor.run {
                    testResult = "✅ \(L.apiTestSuccess): \(result.translatedText)"
                    isTesting = false
                }
            } catch {
                await MainActor.run {
                    testResult = "❌ \(error.localizedDescription)"
                    isTesting = false
                }
            }
        }
    }
}

struct CardView<Content: View>: View {
    let icon: String; let iconColor: Color; let title: String
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon).foregroundColor(iconColor)
                    .font(.system(size: 14, weight: .semibold))
                Text(title).font(.headline)
            }
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }
}

struct UsageRow: View {
    let step: String; let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(step).font(.caption).fontWeight(.bold).foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color.blue.opacity(0.7)))
            Text(text).font(.callout)
        }
    }
}
