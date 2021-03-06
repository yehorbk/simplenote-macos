import Foundation
import AppKit


// MARK: - ParentWindowDelegate Protocol
//
protocol ParentWindowDelegate {

    /// Invoked for every Child Window, whenever we're about to send an event.
    /// - Note: Whenever this method returns `true`, the parent window will stop processing the associated event!
    ///
    func processParentWindowEvent(_ event: NSEvent) -> Bool
}


// MARK: - Simplenote Window
//
class Window: NSWindow {

    /// Semaphore Buttons: Quick access reference to the Close / Minimize / Zoom buttons
    ///
    private lazy var buttons: [NSButton] = [.closeButton, .miniaturizeButton, .zoomButton].compactMap { type in
        standardWindowButton(type)
    }

    /// Allows us to adjust the Origin for the Semaphore Buttons (Close / Miniaturize / Zoom)
    ///
    var semaphoreButtonOriginY: CGFloat?

    /// Horizontal Padding to be applied over all of the Semaphore Buttons
    ///
    var semaphoreButtonPaddingX: CGFloat?


    // MARK: - Lifecycle

    deinit {
        stopListeningToNotifications()
    }

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        startListeningToNotifications()
        refreshStyle()
    }

    // MARK: - Overridden API(s)

    override func sendEvent(_ event: NSEvent) {
        let children = childWindows ?? []
        for case let child as ParentWindowDelegate in children where child.processParentWindowEvent(event) {
            return
        }

        super.sendEvent(event)
    }

    override func mouseUp(with event: NSEvent) {
        processDoubleClickOnTitlebarIfNeeded(with: event)
        super.mouseUp(with: event)
    }

    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        relocateSemaphoreButtonsIfNeeded()
    }
}


// MARK: - Initialization
//
private extension Window {

    func startListeningToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshStyle), name: .ThemeDidChange, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - Notification Handlers
//
private extension Window {

    @objc
    func refreshStyle() {
        if SPUserInterface.isSystemThemeSelected {
            appearance = nil
            return
        }

        appearance = NSAppearance.simplenoteAppearance
    }
}


// MARK: - Sempahore
//
private extension Window {

    func relocateSemaphoreButtonsIfNeeded() {
        guard let semaphoreOriginY = semaphoreButtonOriginY, let semaphorePaddingX = semaphoreButtonPaddingX else {
            return
        }

        let directionalMultiplier: CGFloat = isRTL ? -1 : 1

        for button in buttons {
            var origin = button.frame.origin
            guard origin.y != semaphoreOriginY else {
                continue
            }

            origin.y = semaphoreOriginY
            origin.x += semaphorePaddingX * directionalMultiplier
            button.frame.origin = origin
        }
    }
}


// MARK: - Titlebar / DoubleClick Workaround
//
private extension Window {

    /// Whenever a NSWindow instance has the `.fullSizeContentView` mask, the system will simply no longer automatically process
    /// double click events on the Titlebar Area.
    ///
    /// Ref. #1: https://github.com/Automattic/simplenote-macos/issues/773
    /// Ref. #2: https://stackoverflow.com/questions/52150960/double-click-on-transparent-nswindow-title-does-not-maximize-the-window/61712229#61712229
    ///
    func processDoubleClickOnTitlebarIfNeeded(with event: NSEvent) {
        guard styleMask.contains(.fullSizeContentView),
              event.clickCount >= 2,
              titlebarRect.contains(event.locationInWindow)
        else {
            return
        }

        self.performZoom(nil)
    }
}
