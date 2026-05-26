import AppKit
import ApplicationServices

class ClipboardManager {
    static let shared = ClipboardManager()
    var previousApp: NSRunningApplication?

    private enum KeyCode {
        static let c: UInt16 = 8
        static let v: UInt16 = 9
    }

    private init() {}

    func waitForModifiersReleasePublic() {
        for _ in 0..<40 {
            let flags = CGEventSource.flagsState(.hidSystemState)
            let modifiers: CGEventFlags = [.maskCommand, .maskShift, .maskAlternate, .maskControl]
            if flags.intersection(modifiers).isEmpty {
                return
            }
            Thread.sleep(forTimeInterval: 0.05)
        }
    }

    func getSelectedTextMainThread() -> String? {
        guard let prev = previousApp else {
            NSLog("FlipLingo: no previousApp")
            return nil
        }

        // Method 1: AXUIElement
        let pid = prev.processIdentifier
        let app = AXUIElementCreateApplication(pid)

        var focusedElement: AnyObject?
        let focusResult = AXUIElementCopyAttributeValue(app, kAXFocusedUIElementAttribute as CFString, &focusedElement)

        if focusResult == .success, let element = focusedElement {
            var selectedText: AnyObject?
            let textResult = AXUIElementCopyAttributeValue(element as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedText)
            if textResult == .success, let text = selectedText as? String, !text.isEmpty {
                NSLog("FlipLingo: AX got text: \(text.prefix(50))")
                return text
            }
            NSLog("FlipLingo: AX selectedText failed (\(textResult.rawValue)), trying clipboard fallback")
        } else {
            NSLog("FlipLingo: AX focusedElement failed (\(focusResult.rawValue)), trying clipboard fallback")
        }

        // Method 2: Clipboard fallback (Slack, Chrome, Electron apps)
        prev.activate()
        Thread.sleep(forTimeInterval: 0.15)

        let pasteboard = NSPasteboard.general
        let oldContents = pasteboard.string(forType: .string)
        let oldChangeCount = pasteboard.changeCount

        sendCommandKeystroke(keyCode: KeyCode.c)

        var copiedText: String?
        for _ in 0..<20 {
            Thread.sleep(forTimeInterval: 0.05)
            if pasteboard.changeCount != oldChangeCount {
                copiedText = pasteboard.string(forType: .string)
                NSLog("FlipLingo: clipboard fallback got text: \(copiedText?.prefix(50) ?? "(nil)")")
                break
            }
        }
        if copiedText == nil {
            NSLog("FlipLingo: clipboard fallback failed (no change after 1s)")
        }

        if let old = oldContents {
            pasteboard.clearContents()
            pasteboard.setString(old, forType: .string)
        }

        return copiedText
    }

    func replaceSelectedTextMainThread(with text: String) {
        guard let prev = previousApp else { return }

        // Method 1: AXUIElement
        let pid = prev.processIdentifier
        let app = AXUIElementCreateApplication(pid)

        var focusedElement: AnyObject?
        let focusResult = AXUIElementCopyAttributeValue(app, kAXFocusedUIElementAttribute as CFString, &focusedElement)

        if focusResult == .success, let element = focusedElement {
            let axElement = element as! AXUIElement

            // Read current selected text before attempting set
            var beforeText: AnyObject?
            AXUIElementCopyAttributeValue(axElement, kAXSelectedTextAttribute as CFString, &beforeText)
            let originalSelected = beforeText as? String

            let setResult = AXUIElementSetAttributeValue(axElement, kAXSelectedTextAttribute as CFString, text as CFTypeRef)
            if setResult == .success {
                // Verify: if selected text still matches original, AX set was ineffective
                var afterText: AnyObject?
                AXUIElementCopyAttributeValue(axElement, kAXSelectedTextAttribute as CFString, &afterText)
                let afterSelected = afterText as? String
                if afterSelected != originalSelected {
                    NSLog("FlipLingo: AX replace success")
                    return
                }
                NSLog("FlipLingo: AX replace reported success but text unchanged, falling back to paste")
            } else {
                NSLog("FlipLingo: AX replace failed (\(setResult.rawValue)), falling back to paste")
            }
        }

        // Method 2: Clipboard + Cmd+V fallback
        prev.activate()
        Thread.sleep(forTimeInterval: 0.15)

        let pasteboard = NSPasteboard.general
        let oldContents = pasteboard.string(forType: .string)

        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        sendCommandKeystroke(keyCode: KeyCode.v)
        Thread.sleep(forTimeInterval: 0.3)

        if let old = oldContents {
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                pasteboard.clearContents()
                pasteboard.setString(old, forType: .string)
            }
        }
    }

    private func sendCommandKeystroke(keyCode: UInt16) {
        let source = CGEventSource(stateID: .hidSystemState)

        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) else {
            NSLog("FlipLingo: CGEvent creation failed")
            return
        }

        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand

        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }
}
