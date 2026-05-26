import SwiftUI
import AppKit
import Carbon

struct ShortcutRecorderView: View {
    @State private var isRecording = false
    @State var displayString: String
    let onRecord: (UInt16, NSEvent.ModifierFlags) -> Void

    var body: some View {
        Button(action: { isRecording = true }) {
            Text(isRecording ? L.shortcutRecordPrompt : displayString)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(isRecording ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.2))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isRecording ? Color.accentColor : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        .background(isRecording ? ShortcutKeyListener(onKeyPress: { keyCode, modifiers in
            let mods = modifiers.intersection([.command, .shift, .option, .control])
            guard !mods.isEmpty else { return }
            onRecord(keyCode, mods)
            let carbon = HotkeyManager.carbonModifiers(from: mods)
            displayString = HotkeyManager.shared.displayString(keyCode: UInt32(keyCode), modifiers: carbon)
            isRecording = false
        }) : nil)
    }
}

struct ShortcutKeyListener: NSViewRepresentable {
    let onKeyPress: (UInt16, NSEvent.ModifierFlags) -> Void

    func makeNSView(context: Context) -> KeyListenerView {
        let view = KeyListenerView()
        view.onKeyPress = onKeyPress
        DispatchQueue.main.async { view.window?.makeFirstResponder(view) }
        return view
    }

    func updateNSView(_ nsView: KeyListenerView, context: Context) {
        nsView.onKeyPress = onKeyPress
        DispatchQueue.main.async { nsView.window?.makeFirstResponder(nsView) }
    }
}

class KeyListenerView: NSView {
    var onKeyPress: ((UInt16, NSEvent.ModifierFlags) -> Void)?
    override var acceptsFirstResponder: Bool { true }
    override func keyDown(with event: NSEvent) {
        onKeyPress?(event.keyCode, event.modifierFlags)
    }
}
