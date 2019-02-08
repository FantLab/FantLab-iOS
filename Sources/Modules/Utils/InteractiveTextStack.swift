import Foundation
import UIKit
import ALLKit

public struct InteractiveTextStack: SizeProvider {
    public typealias LinkRange = (url: URL, range: NSRange)

    private let textContainer: NSTextContainer
    private let layoutManager: NSLayoutManager
    private let textStorage: NSTextStorage
    private let linkRanges: [LinkRange]

    public init(string: NSAttributedString, linkAttribute: NSAttributedString.Key) {
        textContainer = NSTextContainer()
        textContainer.exclusionPaths = []
        textContainer.maximumNumberOfLines = 0
        textContainer.lineFragmentPadding = 0

        layoutManager = NSLayoutManager()
        layoutManager.allowsNonContiguousLayout = false
        layoutManager.showsInvisibleCharacters = false
        layoutManager.showsControlCharacters = false
        layoutManager.usesFontLeading = false
        layoutManager.addTextContainer(textContainer)

        textStorage = NSTextStorage(attributedString: string)
        textStorage.addLayoutManager(layoutManager)

        var tmp: [LinkRange] = []

        textStorage.enumerateAttribute(linkAttribute, in: textStorage.fullRange) { (value, range, _) in
            if let url = value as? URL {
                tmp.append((url, range))
            }
        }

        self.linkRanges = tmp
    }

    public func characterIndexAt(point: CGPoint) -> Int? {
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        return index != NSNotFound ? index : nil
    }

    public func linkRangeAt(characterIndex: Int) -> LinkRange? {
        return linkRanges.first(where: { $0.range.contains(characterIndex) })
    }

    public func selectionPathFor(glyphRange: NSRange) -> UIBezierPath {
        let path = UIBezierPath()

        layoutManager.enumerateEnclosingRects(forGlyphRange: glyphRange, withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0), in: textContainer) { (rect, _) in
            path.append(UIBezierPath(roundedRect: rect, cornerRadius: 2))
        }

        return path
    }

    public func render(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }

        let glyphRange = layoutManager.glyphRange(for: textContainer)
        layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: .zero)

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    // MARK: - SizeProvider

    public func calculateSize(with constraints: SizeConstraints) -> CGSize {
        textContainer.size = CGSize(
            width: constraints.width ?? .greatestFiniteMagnitude,
            height: constraints.height ?? .greatestFiniteMagnitude
        )

        let size = layoutManager.usedRect(for: textContainer).size

        textContainer.size = size

        return size
    }
}
