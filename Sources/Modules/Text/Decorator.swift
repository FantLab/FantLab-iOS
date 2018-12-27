import Foundation
import UIKit

public final class TextDecorator {
    public typealias Attributes = [NSAttributedString.Key: Any]

    public let defaultAttributes: Attributes
    public let quoteAttributes: Attributes
    public let linkAttributes: Attributes
    public let boldFont: UIFont
    public let italicFont: UIFont

    public init(defaultAttributes: Attributes,
                quoteAttributes: Attributes,
                linkAttributes: Attributes,
                boldFont: UIFont,
                italicFont: UIFont) {

        self.defaultAttributes = defaultAttributes
        self.quoteAttributes = quoteAttributes
        self.linkAttributes = linkAttributes
        self.boldFont = boldFont
        self.italicFont = italicFont
    }
}
