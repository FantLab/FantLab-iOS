import Foundation
import UIKit
import FLKit

public final class FLText {
    public static let linkAttribute: NSAttributedString.Key = NSAttributedString.Key(rawValue: "FLLink")

    public enum Item {
        case string(NSAttributedString)
        case hidden(string: NSAttributedString, name: String)
        case quote(NSAttributedString)
        case image(URL)
        case photo(Int)
        case video(URL)
    }

    public let items: [Item]
    public let decorator: TextDecorator

    public init(string: String, decorator: TextDecorator, setupLinkAttribute: Bool) {
        items = FLTextBuilder.makeTextItemsFrom(
            string: string,
            decorator: decorator,
            setupLinkAttribute: setupLinkAttribute
        )

        self.decorator = decorator
    }
}

private final class FLTextBuilder {
    static func makeTextItemsFrom(string: String,
                                  decorator: TextDecorator,
                                  setupLinkAttribute: Bool) -> [FLText.Item] {
        let node = FLTextParser.parse(string: string)
        let textData = collectTextDataFrom(node: node)

        var items: [FLText.Item] = []

        do {
            let mutableString = NSMutableAttributedString(
                string: textData.string,
                attributes: decorator.defaultAttributes
            )

            mutableString.beginEditing()

            textData.nodeRanges.forEach { (node, range) in
                let nsRange = range.nsRange(in: textData.string)

                switch node.tag.name {
                case "b":
                    mutableString.addAttribute(.font, value: decorator.boldFont, range: nsRange)
                case "i":
                    mutableString.addAttribute(.font, value: decorator.italicFont, range: nsRange)
                case "u":
                    mutableString.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: nsRange)
                case "s":
                    mutableString.addAttribute(.strikethroughStyle, value: NSNumber(value: 1), range: nsRange)
                case "a", "url", "link":
                    if let url = URL(string: node.tag.value), canOpen(url: url) {
                        mutableString.addAttributes(decorator.linkAttributes, range: nsRange)

                        if setupLinkAttribute {
                            mutableString.addAttribute(FLText.linkAttribute,
                                                       value: url,
                                                       range: nsRange)
                        }
                    }
                case "autor", "work", "edition", "user":
                    let link = "/\(node.tag.name)\(node.tag.value)"

                    if let url = URL(string: link) {
                        mutableString.addAttributes(decorator.linkAttributes, range: nsRange)

                        if setupLinkAttribute {
                            mutableString.addAttribute(FLText.linkAttribute,
                                                       value: url,
                                                       range: nsRange)
                        }
                    }
                default:
                    break
                }
            }

            mutableString.fixAttributes(in: mutableString.fullRange)
            mutableString.endEditing()

            if textData.lineBreaks.count == 2 {
                items.append(.string(mutableString))
            } else {
                var photoIndex: Int = 0

                zip(textData.lineBreaks.dropLast(), textData.lineBreaks.dropFirst()).forEach { (x, y) in
                    let nsRange = (x.index..<y.index).nsRange(in: textData.string)
                    let string = mutableString.attributedSubstring(from: nsRange)

                    if string.length > 0 {
                        items.append(.string(string))
                    }

                    if let node = y.node {
                        if node.tag.name == "photo" {
                            photoIndex += 1
                        }

                        if let item = makeTextItemFromTag(node: node, decorator: decorator, photoIndex: photoIndex) {
                            items.append(item)
                        }
                    }
                }
            }
        }

        return items
    }

    private static func canOpen(url: URL) -> Bool {
        if let host = url.host, !host.isEmpty, !host.contains("fantlab") {
            return true
        }

        return url.path.firstMatch(for: "(work|autor|edition|user)\\d+") != nil
    }

    private static func makeTextItemFromTag(node: FLTagNode, decorator: TextDecorator, photoIndex: Int) -> FLText.Item? {
        let string = FLPlainStringBuilder.makeStringFrom(node: node, tagReplacements: [:])

        switch node.tag.name {
        case "img":
            if let url = URL(string: node.tag.value.nilIfEmpty ?? string) {
                return .image(url)
            }

            return nil
        case "photo":
            return .photo(photoIndex)
        case "video":
            if let url = URL(string: node.tag.value) {
                return .video(url)
            }

            return nil
        case "h", "spoiler":
            let name = node.tag.name == "spoiler" ? "Спойлер" : "Скрытый текст"

            return .hidden(string: NSAttributedString(
                string: string,
                attributes: decorator.defaultAttributes
            ), name: name)
        case "q":
            return .quote(NSAttributedString(
                string: string,
                attributes: decorator.quoteAttributes
            ))
        default:
            return nil
        }
    }

    // MARK: -

    private final class TextData {
        typealias NodeRange = (node: FLTagNode, range: Range<String.Index>)
        typealias LineBreak = (node: FLTagNode?, index: String.Index)

        var string: String = ""
        var nodeRanges: [NodeRange] = []
        var lineBreaks: [LineBreak] = []
    }

    private static func collectTextDataFrom(node: FLTagNode) -> TextData {
        let textData = TextData()
        textData.lineBreaks.append((nil, textData.string.startIndex))
        traverse(node: node, textData: textData)
        textData.lineBreaks.append((nil, textData.string.endIndex))
        return textData
    }

    // MARK: -

    private struct LineBreakTags {
        static let empty = ["br", "hr"]
        static let withContent = ["img", "photo", "video", "h", "spoiler", "q"]
    }

    private static func traverse(node: FLTagNode, textData: TextData) {
        let startIndex = textData.string.endIndex

        if LineBreakTags.empty.contains(node.tag.name) {
            textData.lineBreaks.append((nil, startIndex))
        } else if LineBreakTags.withContent.contains(node.tag.name) {
            textData.lineBreaks.append((node, startIndex))
        } else {
            node.children.forEach { child in
                switch child {
                case .string(let string):
                    if string.maybeHasContent {
                    textData.string.append(string)
                    }
                case .lineBreak:
                    textData.lineBreaks.append((nil, textData.string.endIndex))
                case .node(let node):
                    traverse(node: node, textData: textData)
                }
            }
        }

        let endIndex = textData.string.endIndex

        textData.nodeRanges.append((node, startIndex..<endIndex))
    }
}
