import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    var statusItem: NSStatusItem!
    private var animationTimer: Timer?
    private var animationFrames: [NSImage] = []
    private var currentFrame: Int = 0

    func menuWillOpen(_ menu: NSMenu) {
        ClipboardManager.shared.previousApp = NSWorkspace.shared.frontmostApplication
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        NSLog("FlipLingo: accessibility trusted=\(trusted)")

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        let bundle = Bundle.main
        for i in 0..<4 {
            if let path = bundle.path(forResource: "PacFrame\(i)", ofType: "png"),
               let img = NSImage(contentsOfFile: path) {
                img.isTemplate = true
                img.size = NSSize(width: 18, height: 18)
                animationFrames.append(img)
            }
        }

        if let button = statusItem.button {
            if !animationFrames.isEmpty {
                button.image = animationFrames[0]
            } else {
                button.title = "訳"
            }
            button.toolTip = L.menuBarTooltip
        }

        startAnimation()
        buildMenu()
        HotkeyManager.shared.register()
    }

    func buildMenu() {
        let menu = NSMenu()
        menu.delegate = self
        menu.addItem(NSMenuItem(title: "FlipLingo", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())

        let translateItem = NSMenuItem(title: L.menuTranslate, action: #selector(translateSelected), keyEquivalent: "")
        translateItem.target = self
        menu.addItem(translateItem)

        let previewItem = NSMenuItem(title: L.menuPreview, action: #selector(previewSelected), keyEquivalent: "")
        previewItem.target = self
        menu.addItem(previewItem)

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(title: L.menuSettings, action: #selector(openSettings), keyEquivalent: "")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: L.menuQuit, action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    func startAnimation() {
        guard !animationFrames.isEmpty else { return }
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentFrame = (self.currentFrame + 1) % self.animationFrames.count
            self.statusItem.button?.image = self.animationFrames[self.currentFrame]
        }
    }

    @objc func translateSelected() {
        ClipboardManager.shared.previousApp = NSWorkspace.shared.frontmostApplication
        HotkeyManager.shared.performTranslation(mode: .replace)
    }

    @objc func previewSelected() {
        ClipboardManager.shared.previousApp = NSWorkspace.shared.frontmostApplication
        HotkeyManager.shared.performTranslation(mode: .preview)
    }

    @objc func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        for window in NSApp.windows where window.title.contains("設定") || window.title.contains("설정") {
            window.makeKeyAndOrderFront(nil)
            return
        }
        let hostingController = NSHostingController(rootView: SettingsView())
        let window = NSWindow(contentViewController: hostingController)
        window.title = L.settingsTitle
        window.setContentSize(NSSize(width: 500, height: 720))
        window.styleMask = [.titled, .closable]
        window.center()
        window.makeKeyAndOrderFront(nil)
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
