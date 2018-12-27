public final class FLStringPreview {
    public let value: String

    public init(string: String) {
        let node = FLTextParser.parse(string: string)

        value = FLPlainStringBuilder.makeStringFrom(node: node, tagReplacements: TagReplacements.preview)
    }
}

enum ReplacementRule {
    case string(String)
    case lineBreak
}

typealias ReplacementRules = [String: ReplacementRule]

struct TagReplacements {
    static let preview: ReplacementRules = [
        "br": .lineBreak,
        "hr": .lineBreak,
        "img": .string("ИЗОБРАЖЕНИЕ"),
        "video": .string("ВИДЕО"),
        "h": .string("СКРЫТЫЙ ТЕКСТ"),
        "spoiler": .string("СПОЙЛЕР")
    ]
}

final class FLPlainStringBuilder {
    static func makeStringFrom(node: FLTagNode, tagReplacements: ReplacementRules) -> String {
        var string = ""
        traverse(node: node, string: &string, tagReplacements: tagReplacements)
        return string
    }

    private static func traverse(node: FLTagNode, string: inout String, tagReplacements: ReplacementRules) {
        if let replacement = tagReplacements[node.tag.name] {
            switch replacement {
            case let .string(value):
                string.append(value)
            case .lineBreak:
                insertLineBreak(&string)
            }
        } else {
            node.children.forEach { child in
                switch child {
                case .string(let value):
                    string.append(value)
                case .lineBreak:
                    insertLineBreak(&string)
                case .node(let node):
                    traverse(node: node, string: &string, tagReplacements: tagReplacements)
                }
            }
        }
    }

    private static let newLineCharacter: Character = "\n"

    private static func insertLineBreak(_ string: inout String) {
        guard !string.isEmpty, string.last != newLineCharacter else {
            return
        }

        string.append(newLineCharacter)
    }
}
