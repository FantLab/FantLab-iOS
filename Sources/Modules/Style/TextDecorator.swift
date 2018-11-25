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
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 3
//        paragraphStyle.paragraphSpacing = 2
//        paragraphStyle.paragraphSpacingBefore = 2
//        paragraphStyle.lineBreakMode = .byTruncatingTail // ???

        string.addAttributes(
            [
                .font: AppStyle.shared.fonts.regularFont(ofSize: fontSize),
                .foregroundColor: AppStyle.shared.colors.textMainColor
            ],
            range: range
        )
    }

    public func setupBoldIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.font, value: AppStyle.shared.fonts.boldFont(ofSize: fontSize), range: range)
    }

    public func setupItalicIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.font, value: AppStyle.shared.fonts.italicFont(ofSize: fontSize), range: range)
    }

    public func setupUnderlineIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: range)
    }

    public func setupStrikethroughIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.strikethroughStyle, value: NSNumber(value: 1), range: range)
    }

    public func setupQuoteIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.font, value: AppStyle.shared.fonts.italicFont(ofSize: fontSize), range: range)
    }

    public func setupTapAreaIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.font, value: AppStyle.shared.fonts.boldFont(ofSize: fontSize), range: range)
    }

    public func setupLinkIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: range)
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
                .font: AppStyle.shared.fonts.regularFont(ofSize: fontSize),
                .foregroundColor: AppStyle.shared.colors.textMainColor,
                .paragraphStyle: paragraphStyle
            ],
            range: range
        )
    }

    public func setupBoldIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.font, value: AppStyle.shared.fonts.boldFont(ofSize: fontSize), range: range)
    }

    public func setupItalicIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.font, value: AppStyle.shared.fonts.italicFont(ofSize: fontSize), range: range)
    }

    public func setupUnderlineIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: range)
    }

    public func setupStrikethroughIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.strikethroughStyle, value: NSNumber(value: 1), range: range)
    }

    public func setupQuoteIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttribute(.font, value: AppStyle.shared.fonts.italicFont(ofSize: fontSize), range: range)
    }

    public func setupTapAreaIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttributes(
            [
                .foregroundColor: AppStyle.shared.colors.textTapAreaForegroundColor,
                .backgroundColor: AppStyle.shared.colors.textTapAreaBackgroundColor,
                .font: AppStyle.shared.fonts.boldFont(ofSize: fontSize)
            ],
            range: range
        )
    }

    public func setupLinkIn(range: NSRange, string: NSMutableAttributedString) {
        string.addAttributes(
            [
                .underlineStyle: NSNumber(value: NSUnderlineStyle.single.rawValue),
                .foregroundColor: AppStyle.shared.colors.textLinkColor
            ],
            range: range
        )
    }
}
