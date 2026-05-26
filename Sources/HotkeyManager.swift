import AppKit
import Carbon

private func carbonHotKeyHandler(
    nextHandler: EventHandlerCallRef?,
    event: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    var hotKeyID = EventHotKeyID()
    GetEventParameter(event!, UInt32(kEventParamDirectObject), UInt32(typeEventHotKeyID),
                      nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)

    DispatchQueue.main.async {
        if hotKeyID.id == 1 {
            NSLog("FlipLingo: Hotkey 1 (replace) fired")
            HotkeyManager.shared.performTranslation(mode: .replace)
        } else if hotKeyID.id == 2 {
            NSLog("FlipLingo: Hotkey 2 (preview) fired")
            HotkeyManager.shared.performTranslation(mode: .preview)
        }
    }
    return noErr
}

enum TranslationMode {
    case replace  // Translate and replace selected text (or show preview if enabled)
    case preview  // Always show preview popup (read-only)
}

class HotkeyManager {
    static let shared = HotkeyManager()
    private var hotKeyRef1: EventHotKeyRef?
    private var hotKeyRef2: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

    // Hotkey 1: Replace/translate (default ⌘⇧T)
    var hotkeyKeyCode: UInt32 {
        get {
            let val = UserDefaults.standard.integer(forKey: "hotkey_keycode")
            return val != 0 ? UInt32(val) : UInt32(kVK_ANSI_T)
        }
        set { UserDefaults.standard.set(Int(newValue), forKey: "hotkey_keycode") }
    }

    var hotkeyModifiers: UInt32 {
        get {
            let val = UserDefaults.standard.integer(forKey: "hotkey_modifiers")
            return val != 0 ? UInt32(val) : UInt32(cmdKey | shiftKey)
        }
        set { UserDefaults.standard.set(Int(newValue), forKey: "hotkey_modifiers") }
    }

    // Hotkey 2: Preview only (default ⌘⇧Y)
    var previewKeyCode: UInt32 {
        get {
            let val = UserDefaults.standard.integer(forKey: "preview_keycode")
            return val != 0 ? UInt32(val) : UInt32(kVK_ANSI_Y)
        }
        set { UserDefaults.standard.set(Int(newValue), forKey: "preview_keycode") }
    }

    var previewModifiers: UInt32 {
        get {
            let val = UserDefaults.standard.integer(forKey: "preview_modifiers")
            return val != 0 ? UInt32(val) : UInt32(cmdKey | shiftKey)
        }
        set { UserDefaults.standard.set(Int(newValue), forKey: "preview_modifiers") }
    }

    func register() {
        unregister()

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            carbonHotKeyHandler,
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )

        // Register hotkey 1 (replace)
        var hotKeyID1 = EventHotKeyID(signature: OSType(0x4A4B5452), id: 1)
        RegisterEventHotKey(hotkeyKeyCode, hotkeyModifiers, hotKeyID1,
                           GetApplicationEventTarget(), 0, &hotKeyRef1)
        NSLog("FlipLingo: Hotkey1 registered keyCode=\(hotkeyKeyCode) mods=\(hotkeyModifiers)")

        // Register hotkey 2 (preview)
        var hotKeyID2 = EventHotKeyID(signature: OSType(0x4A4B5452), id: 2)
        RegisterEventHotKey(previewKeyCode, previewModifiers, hotKeyID2,
                           GetApplicationEventTarget(), 0, &hotKeyRef2)
        NSLog("FlipLingo: Hotkey2 registered keyCode=\(previewKeyCode) mods=\(previewModifiers)")
    }

    func unregister() {
        if let ref = hotKeyRef1 { UnregisterEventHotKey(ref); hotKeyRef1 = nil }
        if let ref = hotKeyRef2 { UnregisterEventHotKey(ref); hotKeyRef2 = nil }
        if let ref = eventHandlerRef { RemoveEventHandler(ref); eventHandlerRef = nil }
    }

    func performTranslation(mode: TranslationMode) {
        ClipboardManager.shared.previousApp = NSWorkspace.shared.frontmostApplication

        DispatchQueue.global(qos: .userInitiated).async {
            ClipboardManager.shared.waitForModifiersReleasePublic()

            let selectedText = ClipboardManager.shared.getSelectedTextMainThread()

            guard let text = selectedText,
                  !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "FlipLingo"
                    alert.informativeText = L.noTextSelected
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
                return
            }

            let targetLang: String
            switch mode {
            case .replace:
                targetLang = UserDefaults.standard.string(forKey: "target_language") ?? "KO"
            case .preview:
                targetLang = UserDefaults.standard.string(forKey: "preview_target_language") ?? "JA"
            }

            Task {
                do {
                    let result = try await TranslationService.shared.translate(text, targetOverride: targetLang)
                    await MainActor.run {
                        switch mode {
                        case .preview:
                            TranslationPopup.shared.show(result: result)
                        case .replace:
                            let previewEnabled = UserDefaults.standard.object(forKey: "preview_enabled") == nil
                                ? true
                                : UserDefaults.standard.bool(forKey: "preview_enabled")
                            if previewEnabled {
                                TranslationPopup.shared.show(result: result)
                            } else {
                                ClipboardManager.shared.replaceSelectedTextMainThread(with: result.translatedText)
                            }
                        }
                    }
                } catch {
                    await MainActor.run {
                        let alert = NSAlert()
                        alert.messageText = L.translationError
                        alert.informativeText = error.localizedDescription
                        alert.alertStyle = .warning
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                    }
                }
            }
        }
    }

    // Convert NSEvent modifierFlags to Carbon modifiers
    static func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var carbon: UInt32 = 0
        if flags.contains(.command) { carbon |= UInt32(cmdKey) }
        if flags.contains(.shift) { carbon |= UInt32(shiftKey) }
        if flags.contains(.option) { carbon |= UInt32(optionKey) }
        if flags.contains(.control) { carbon |= UInt32(controlKey) }
        return carbon
    }

    var shortcutDisplayString: String {
        displayString(keyCode: hotkeyKeyCode, modifiers: hotkeyModifiers)
    }

    var previewShortcutDisplayString: String {
        displayString(keyCode: previewKeyCode, modifiers: previewModifiers)
    }

    func displayString(keyCode: UInt32, modifiers: UInt32) -> String {
        var parts: [String] = []
        if modifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
        if modifiers & UInt32(optionKey) != 0 { parts.append("⌥") }
        if modifiers & UInt32(shiftKey) != 0 { parts.append("⇧") }
        if modifiers & UInt32(cmdKey) != 0 { parts.append("⌘") }
        parts.append(Self.keyName(for: keyCode))
        return parts.joined()
    }

    static func keyName(for keyCode: UInt32) -> String {
        let map: [UInt32: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
            8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
            16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
            23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
            30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 37: "L",
            38: "J", 39: "'", 40: "K", 41: ";", 42: "\\", 43: ",", 44: "/",
            45: "N", 46: "M", 47: ".", 49: "Space", 50: "`",
        ]
        return map[keyCode] ?? "Key\(keyCode)"
    }

    deinit { unregister() }
}
