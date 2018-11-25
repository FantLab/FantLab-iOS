import Foundation
import UIKit
import FantLabUtils
import FantLabStyle

public final class FLAttributedText {
    public enum Attachment {
        case hiddenText(String) // plain string
        case link(String) // url
        case image(String) // url
        case video(String) // url
        case entity(String, String) // name id
    }

    public typealias AttachmentRange = (attachment: Attachment, range: NSRange)

    public let string: NSAttributedString
    public let attachmentRanges: [AttachmentRange]

    init(string: NSAttributedString, attachmentRanges: [AttachmentRange]) {
        self.string = string
        self.attachmentRanges = attachmentRanges
    }
}

extension FLAttributedText {
    public convenience init(taggedString: String,
                            decorator: TextDecorator,
                            replacementRules: ReplacementRules) {
        let node = FLTextParser.parse(string: taggedString)

        let combinedReplacementRules = TagReplacementRules.defaults.merging(replacementRules) { (_, new) in new }

        let text = FLTextBuilder.makeTextFrom(node: node, replacementRules: combinedReplacementRules)

        var attachmentRanges: [AttachmentRange] = []

        let mutableString = NSMutableAttributedString(string: text.string)
        mutableString.beginEditing()

        decorator.setupDefaultAttributesIn(range: mutableString.fullRange, string: mutableString)

        text.nodeRanges.forEach { (node, range) in
            guard let tagName = TagName(rawValue: node.tag.name) else {
                return
            }

            let nsRange = range.nsRange

            switch tagName {
            case .b:
                decorator.setupBoldIn(range: nsRange, string: mutableString)
            case .i:
                decorator.setupItalicIn(range: nsRange, string: mutableString)
            case .u:
                decorator.setupUnderlineIn(range: nsRange, string: mutableString)
            case .s:
                decorator.setupStrikethroughIn(range: nsRange, string: mutableString)
            case .q:
                decorator.setupQuoteIn(range: nsRange, string: mutableString)
            case .h, .spoiler:
                decorator.setupTapAreaIn(range: nsRange, string: mutableString)

                let string = FLTextBuilder.makeTextFrom(node: node, replacementRules: TagReplacementRules.defaults).string

                attachmentRanges.append((.hiddenText(string), nsRange))
            case .img:
                decorator.setupTapAreaIn(range: nsRange, string: mutableString)

                let url = node.tag.value.nilIfEmpty ?? String(text.string[range])

                attachmentRanges.append((.image(url), nsRange))
            case .video:
                decorator.setupTapAreaIn(range: nsRange, string: mutableString)

                let url = node.tag.value

                attachmentRanges.append((.video(url), nsRange))
            case .a, .url, .link:
                decorator.setupLinkIn(range: nsRange, string: mutableString)

                attachmentRanges.append((.link(node.tag.value), nsRange))
            case .autor, .work, .edition, .person, .user, .art, .dictor, .series, .film, .translator:
                decorator.setupLinkIn(range: nsRange, string: mutableString)

                attachmentRanges.append((.entity(node.tag.name, node.tag.value), nsRange))
            }
        }

        mutableString.endEditing()

        self.init(string: mutableString, attachmentRanges: attachmentRanges)
    }
}

enum TagName: String {
    case b, i, u, s
    case q
    case h, spoiler
    case img
    case video
    case a, url, link
    case autor, work, edition, person, user, art, dictor, series, film, translator
}
