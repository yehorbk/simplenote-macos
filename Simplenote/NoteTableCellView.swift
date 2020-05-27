import Foundation
import AppKit


// MARK: - TagTableCellView
//
@objcMembers
class NoteTableCellView: NSTableCellView {

    /// TextField: Title
    ///
    @IBOutlet private var titleTextField: NSTextField!

    /// TextField: Body
    ///
    @IBOutlet private var bodyTextField: NSTextField!

    /// LeftImage: Pinned Indicator
    ///
    @IBOutlet private var pinnedImageView: NSImageView!

    /// RightImage: Shared Indicator
    ///
    @IBOutlet private var sharedImageView: NSImageView!

    /// Indicates if the receiver displays the pinned indicator
    ///
    var displaysPinnedIndicator: Bool {
        get {
            !pinnedImageView.isHidden
        }
        set {
            pinnedImageView.isHidden = !newValue
        }
    }

    /// Indicates if the receiver displays the shared indicator
    ///
    var displaysSharedIndicator: Bool {
        get {
            !sharedImageView.isHidden
        }
        set {
            sharedImageView.isHidden = !newValue
        }
    }

    /// In condensed mode we simply won't render the bodyTextField
    ///
    var rendersInCondensedMode: Bool {
        get {
            bodyTextField.isHidden
        }
        set {
            bodyTextField.isHidden = newValue
        }
    }

    /// Note's Title String
    ///
    var title: String? {
        get {
            titleTextField.stringValue
        }
        set {
            titleTextField.stringValue = newValue ?? String()
        }
    }

    /// Note's Body String
    ///
    var body: String? {
        get {
            bodyTextField.stringValue
        }
        set {
            bodyTextField.stringValue = newValue ?? String()
        }
    }


    // MARK: - Overridden Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTitleField()
        setupBodyField()
        setupLeftImage()
        setupRightImage()
    }
}


// MARK: - Interface Initialization
//
private extension NoteTableCellView {

    func setupTitleField() {
        titleTextField.maximumNumberOfLines = Metrics.maximumNumberOfTitleLines
        titleTextField.textColor = .simplenoteTextColor
    }

    func setupBodyField() {
        bodyTextField.maximumNumberOfLines = Metrics.maximumNumberOfBodyLines
        bodyTextField.textColor = .simplenoteSecondaryTextColor
    }

    func setupLeftImage() {
        // We *don't wanna use* `imageView.contentTintColor` since on highlight it's automatically changing the tintColor!
        let image = NSImage(named: .pin)
        pinnedImageView.image = image?.tinted(with: .simplenoteActionButtonTintColor)
    }

    func setupRightImage() {
        let image = NSImage(named: .shared)
        sharedImageView.image = image?.tinted(with: .simplenoteSecondaryTextColor)
    }
}


// MARK: - Interface Initialization
//
extension NoteTableCellView {

    /// Returns the Height that the receiver would require to be rendered, given the current User Settings (number of preview lines).
    ///
    /// Note: Why these calculations? (1) Performance and (2) we need to enforce two body lines
    ///
    @objc
    static var rowHeight: CGFloat {
        let outerInsets = Metrics.outerVerticalStackViewInsets
        let insertTitleHeight = outerInsets.top + Metrics.lineHeightForTitle + outerInsets.bottom

        if Options.shared.notesListCondensed {
            return insertTitleHeight
        }

        let bodyHeight = CGFloat(Metrics.maximumNumberOfBodyLines) * Metrics.lineHeightForBody
        return insertTitleHeight + Metrics.outerVerticalStackViewSpacing + bodyHeight
    }
}


// MARK: - Metrics!
//
private enum Metrics {
    static let lineHeightForTitle = Fonts.title.boundingRectForFont.height.rounded(.up)
    static let lineHeightForBody = Fonts.body.boundingRectForFont.height.rounded(.up)
    static let maximumNumberOfTitleLines = 1
    static let maximumNumberOfBodyLines = 2
    static let outerVerticalStackViewInsets = NSEdgeInsets(top: 8, left: 24, bottom: 8, right: 16)
    static let outerVerticalStackViewSpacing = CGFloat(2)
}


// MARK: - Interface Settings
//
private enum Fonts {
    static let title = NSFont.systemFont(ofSize: 14)
    static let body = NSFont.systemFont(ofSize: 12)
}