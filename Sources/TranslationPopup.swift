import SwiftUI
import AppKit

class TranslationPopup {
    static let shared = TranslationPopup()
    private var popupWindow: NSWindow?
    private init() {}

    func show(result: TranslationResult) {
        closeExisting()

        let directionLabel = "\(result.sourceLang) → \(result.targetLang)"

        let contentView = PopupContentView(
            originalText: result.originalText,
            translatedText: result.translatedText,
            directionLabel: directionLabel,
            onApply: { [weak self] in
                ClipboardManager.shared.replaceSelectedTextMainThread(with: result.translatedText)
                self?.close()
            },
            onCopy: { [weak self] in
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(result.translatedText, forType: .string)
                self?.close()
            },
            onCancel: { [weak self] in
                self?.close()
            }
        )

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 420, height: 300)

        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 300),
            styleMask: [.titled, .closable, .nonactivatingPanel, .hudWindow],
            backing: .buffered, defer: false
        )
        window.title = "FlipLingo"
        window.contentView = hostingView
        window.isFloatingPanel = true
        window.level = .floating
        window.center()
        window.hidesOnDeactivate = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        popupWindow = window
    }

    private func closeExisting() {
        popupWindow?.close()
        popupWindow = nil
    }

    func close() {
        DispatchQueue.main.async { [weak self] in
            self?.popupWindow?.close()
            self?.popupWindow = nil
        }
    }
}

struct PopupContentView: View {
    let originalText: String
    let translatedText: String
    let directionLabel: String
    let onApply: () -> Void
    let onCopy: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "arrow.left.arrow.right")
                Text(directionLabel).font(.headline)
                Spacer()
            }
            .foregroundColor(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text(L.originalText).font(.caption).foregroundColor(.secondary)
                ScrollView {
                    Text(originalText).font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 80).padding(8)
                .background(Color.gray.opacity(0.1)).cornerRadius(6)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(L.translatedText).font(.caption).foregroundColor(.secondary)
                ScrollView {
                    Text(translatedText).font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 80).padding(8)
                .background(Color.blue.opacity(0.05)).cornerRadius(6)
            }

            Divider()

            HStack {
                Button(L.cancel) { onCancel() }
                    .keyboardShortcut(.escape)
                Spacer()
                Button(L.copy) { onCopy() }
                    .keyboardShortcut("c", modifiers: .command)
                Button(L.apply) { onApply() }
                    .keyboardShortcut(.return)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(16)
        .frame(width: 420, height: 300)
    }
}
