import Foundation
import UIKit
import FantLabText

public final class TextStyle {
    public static let defaultTextDecorator: TextDecorator = {
        let defaultParagraphStyle = NSMutableParagraphStyle()
        defaultParagraphStyle.alignment = .left
        defaultParagraphStyle.lineSpacing = 4
        defaultParagraphStyle.paragraphSpacing = 4
        defaultParagraphStyle.paragraphSpacingBefore = 4

        let quoteParagraphStyle = NSMutableParagraphStyle()
        quoteParagraphStyle.alignment = .left
        quoteParagraphStyle.lineSpacing = 4
        quoteParagraphStyle.paragraphSpacing = 4
        quoteParagraphStyle.paragraphSpacingBefore = 4

        return TextDecorator(
            defaultAttributes: [
                .font: Fonts.system.regular(size: 16),
                .foregroundColor: UIColor.black,
                .paragraphStyle: defaultParagraphStyle
            ],
            quoteAttributes: [
                .font: Fonts.system.italic(size: 15),
                .foregroundColor: UIColor.gray,
                .paragraphStyle: quoteParagraphStyle
            ],
            linkAttributes: [
                .foregroundColor: Colors.flOrange,
                .underlineStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)
            ],
            boldFont: Fonts.system.bold(size: 16),
            italicFont: Fonts.system.italic(size: 16)
        )
    }()
}
