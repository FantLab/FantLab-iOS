import Foundation
import UIKit
import FantLabUtils

public protocol TextDecorator: class {
    func setupDefaultAttributesIn(range: NSRange, string: NSMutableAttributedString)
    func setupBoldIn(range: NSRange, string: NSMutableAttributedString)
    func setupItalicIn(range: NSRange, string: NSMutableAttributedString)
    func setupUnderlineIn(range: NSRange, string: NSMutableAttributedString)
    func setupStrikethroughIn(range: NSRange, string: NSMutableAttributedString)
    func setupQuoteIn(range: NSRange, string: NSMutableAttributedString)
    func setupTapAreaIn(range: NSRange, string: NSMutableAttributedString)
    func setupLinkIn(range: NSRange, string: NSMutableAttributedString)
}

public final class PreviewTextDecorator: TextDecorator {
    private let fontSize: CGFloat = 15

    public init() {}

    // MARK: -

    public func setupDefaultAttributesIn(range: NSRange, string: NSMutableAttributedString) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        paragraphStyle.alignment = .left
        paragraphStyle.hyphenationFactor = 1
        paragraphStyle.firstLineHeadIndent = 24
        paragraphStyle.paragraphSpacing = 4
        paragraphStyle.paragraphSpacingBefore = 4

        string.addAttributes(
            [
                .font: Fonts.system.regular(size: fontSize),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ],
            range: range
        )
    }

    public func setupBoldIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.font, value: Fonts.system.medium(size: fontSize), range: range)
    }

    public func setupItalicIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.font, value: Fonts.system.italic(size: fontSize), range: range)
    }

    public func setupUnderlineIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: range)
    }

    public func setupStrikethroughIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.strikethroughStyle, value: NSNumber(value: 1), range: range)
    }

    public func setupQuoteIn(range: NSRange, string: NSMutableAttributedString) {
        setupItalicIn(range: range, string: string)
    }

    public func setupTapAreaIn(range: NSRange, string: NSMutableAttributedString) {
        setupBoldIn(range: range, string: string)
    }

    public func setupLinkIn(range: NSRange, string: NSMutableAttributedString) {
        setupUnderlineIn(range: range, string: string)
    }
}

public final class InteractiveTextDecorator: TextDecorator {
    private let fontSize: CGFloat = 16

    public init() {}

    // MARK: -

    public func setupDefaultAttributesIn(range: NSRange, string: NSMutableAttributedString) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .left
        paragraphStyle.hyphenationFactor = 1
        paragraphStyle.firstLineHeadIndent = 32
        paragraphStyle.paragraphSpacing = 4
        paragraphStyle.paragraphSpacingBefore = 4

        string.addAttributes(
            [
                .font: Fonts.system.regular(size: fontSize),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ],
            range: range
        )
    }

    public func setupBoldIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.font, value: Fonts.system.bold(size: fontSize), range: range)
    }

    public func setupItalicIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.font, value: Fonts.system.italic(size: fontSize), range: range)
    }

    public func setupUnderlineIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: range)
    }

    public func setupStrikethroughIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.strikethroughStyle, value: NSNumber(value: 1), range: range)
    }

    public func setupQuoteIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.font, value: Fonts.system.italic(size: fontSize), range: range)
    }

    public func setupTapAreaIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttributes(
            [
                .foregroundColor: UIColor.white,
                .backgroundColor: Colors.flBlue,
                .font: Fonts.system.medium(size: fontSize)
            ],
            range: range
        )
    }

    public func setupLinkIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttributes(
            [
                .underlineStyle: NSNumber(value: NSUnderlineStyle.single.rawValue),
                .foregroundColor: Colors.flBlue
            ],
            range: range
        )
    }
}
