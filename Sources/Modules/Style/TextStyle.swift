import Foundation
import UIKit
import FLText

public final class TextStyle {
    public static func makeDecoratorWithFontSize(_ fontSize: CGFloat,
                                                  lineSpacing: CGFloat,
                                                  paragraphSpacing: CGFloat,
                                                  defaultTextColor: UIColor = .black) -> TextDecorator {
        let defaultParagraphStyle = NSMutableParagraphStyle()
        defaultParagraphStyle.alignment = .left
        defaultParagraphStyle.lineSpacing = lineSpacing
        defaultParagraphStyle.paragraphSpacing = paragraphSpacing
        defaultParagraphStyle.paragraphSpacingBefore = paragraphSpacing

        let quoteParagraphStyle = NSMutableParagraphStyle()
        quoteParagraphStyle.alignment = .left
        quoteParagraphStyle.lineSpacing = lineSpacing
        quoteParagraphStyle.paragraphSpacing = paragraphSpacing
        quoteParagraphStyle.paragraphSpacingBefore = paragraphSpacing

        return TextDecorator(
            defaultAttributes: [
                .font: Fonts.system.regular(size: fontSize),
                .foregroundColor: defaultTextColor,
                .paragraphStyle: defaultParagraphStyle
            ],
            quoteAttributes: [
                .font: Fonts.system.italic(size: fontSize),
                .foregroundColor: UIColor.gray,
                .paragraphStyle: quoteParagraphStyle
            ],
            linkAttributes: [
                .foregroundColor: Colors.darkOrange,
                .underlineStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)
            ],
            boldFont: Fonts.system.bold(size: fontSize),
            italicFont: Fonts.system.italic(size: fontSize)
        )
    }

    public static let defaultTextDecorator = makeDecoratorWithFontSize(16, lineSpacing: 4, paragraphSpacing: 4)
}
