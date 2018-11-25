import FantLabUtils

private protocol ParseController {
    func save(string: String)
    func open(tag name: String, value: String)
    func close(tag name: String)
}

private protocol CharacterHandler {
    func accept(character: Character) -> Bool
    func flush(to controller: ParseController)
    func nextHandlerWith(terminator: Character) -> CharacterHandler
}

private struct Consts {
    static let singleHTMLTags: Set<String> = ["img", "hr", "br"]
    static let singleBBTags: Set<String> = ["*", "video"]
}

private final class HTMLTagCharacterHandler: CharacterHandler {
    private final class Attribute {
        var name: String = ""
        var value: String = ""

        private var appendToValue: Bool = false

        func append(_ character: Character) {
            switch character {
            case "\"", "“", "'":
                break
            case "=":
                appendToValue = true
            default:
                if appendToValue {
                    value.append(character)
                } else {
                    name.append(character)
                }
            }
        }
    }

    private var name: String = ""
    private var attributes: [String: String] = [:]
    private var attribute: Attribute?
    private var isCloseTag: Bool = false

    func accept(character: Character) -> Bool {
        switch character {
        case ">":
            attribute.flatMap { attributes[$0.name.lowercased()] = $0.value }

            return false
        case " ":
            attribute.flatMap { attributes[$0.name.lowercased()] = $0.value }

            attribute = Attribute()
        case "/":
            if name.isEmpty && !isCloseTag {
                isCloseTag = true
            } else {
                attribute?.append(character)
            }
        default:
            if let attribute = attribute {
                attribute.append(character)
            } else {
                name.append(character)
            }
        }

        return true
    }

    func flush(to controller: ParseController) {
        guard !name.isEmpty else {
            return
        }

        let lowName = name.lowercased()

        let value: String

        switch lowName {
        case "a":
            value = attributes["href"] ?? ""
        case "img":
            value = attributes["src"] ?? ""
        default:
            value = ""
        }

        if Consts.singleHTMLTags.contains(lowName) {
            controller.open(tag: lowName, value: value)
            controller.close(tag: lowName)
        } else {
            if isCloseTag {
                controller.close(tag: lowName)
            } else {
                controller.open(tag: lowName, value: value)
            }
        }
    }

    func nextHandlerWith(terminator: Character) -> CharacterHandler {
        return DefaultCharacterHandler()
    }
}

private final class BBTagCharacterHandler: CharacterHandler {
    private var name: String = ""
    private var value: String = ""
    private var appendToValue: Bool = false
    private var isCloseTag: Bool = false

    func accept(character: Character) -> Bool {
        switch character {
        case "]":
            return false
        case "=":
            if !appendToValue && !isCloseTag {
                appendToValue = true
            } else {
                fallthrough
            }
        case "/":
            if !appendToValue && !isCloseTag && name.isEmpty {
                isCloseTag = true
            } else {
                fallthrough
            }
        default:
            if appendToValue {
                value.append(character)
            } else {
                name.append(character)
            }
        }

        return true
    }

    func flush(to controller: ParseController) {
        guard !name.isEmpty else {
            return
        }

        let lowName = name.lowercased()

        if Consts.singleBBTags.contains(lowName) {
            controller.open(tag: lowName, value: value)
            controller.close(tag: lowName)
        } else {
            if isCloseTag {
                controller.close(tag: lowName)
            } else {
                controller.open(tag: lowName, value: value)
            }
        }
    }

    func nextHandlerWith(terminator: Character) -> CharacterHandler {
        return DefaultCharacterHandler()
    }
}

private final class DefaultCharacterHandler: CharacterHandler {
    private var string: String = ""

    func accept(character: Character) -> Bool {
        switch character {
        case "[", "<", ":":
            return false
        default:
            string.append(character)
        }

        return true
    }

    func flush(to controller: ParseController) {
        guard !string.isEmpty else {
            return
        }

        controller.save(string: string)
    }

    func nextHandlerWith(terminator: Character) -> CharacterHandler {
        switch terminator {
        case "[":
            return BBTagCharacterHandler()
        case "<":
            return HTMLTagCharacterHandler()
        case ":":
            return EmoticonCharacterHandler()
        default:
            return DefaultCharacterHandler()
        }
    }
}

private final class EmoticonCharacterHandler: CharacterHandler {
    private var string: String = ":"

    func accept(character: Character) -> Bool {
        switch character {
        case "[", "<":
            return false
        case ":":
            string.append(character)

            return false
        default:
            string.append(character)
        }

        return Emoticons.trie.hasPathFor(key: string)
    }

    func flush(to controller: ParseController) {
        controller.save(string: Emoticons.trie.valueFor(key: string) ?? string)
    }

    func nextHandlerWith(terminator: Character) -> CharacterHandler {
        switch terminator {
        case "[":
            return BBTagCharacterHandler()
        case "<":
            return HTMLTagCharacterHandler()
        default:
            return DefaultCharacterHandler()
        }
    }
}

struct FLTag {
    let name: String
    let value: String
}

final class FLTagNode {
    enum Child {
        case string(String)
        case node(FLTagNode)
    }

    let tag: FLTag

    init(tag: FLTag) {
        self.tag = tag
    }

    var children: [Child] = []
}

private final class Parser: ParseController {
    private let string: String

    init(string: String) {
        self.string = string
    }

    // MARK: -

    private var nodeStack = Stack<FLTagNode>()

    func parse() -> FLTagNode {
        let rootNode = FLTagNode(tag: FLTag(name: "", value: ""))

        nodeStack.push(rootNode)

        var handler: CharacterHandler = DefaultCharacterHandler()

        string.forEach { character in
            if handler.accept(character: character) {
                return
            }

            handler.flush(to: self)

            handler = handler.nextHandlerWith(terminator: character)
        }

        handler.flush(to: self)

        return rootNode
    }

    // MARK: -

    func save(string: String) {
        nodeStack.peek?.children.append(.string(string))
    }

    func open(tag name: String, value: String) {
        let tag = FLTag(name: name, value: value)
        let node = FLTagNode(tag: tag)
        nodeStack.peek?.children.append(.node(node))
        nodeStack.push(node)
    }

    func close(tag name: String) {
        nodeStack.pop()
    }
}

final class FLTextParser {
    static func parse(string: String) -> FLTagNode {
        return Parser(string: string).parse()
    }
}
