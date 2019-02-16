import FantLabUtils

private protocol ParseController {
    func save(string: String)
    func saveLineBreak()
    func open(tag name: String, value: String)
    func close(tag name: String)
}

private protocol CharacterHandler {
    func accept(character: Character) -> Bool
    func commit(to controller: ParseController, terminator: Character?) -> CharacterHandler
}

private struct Consts {
    static let singleHTMLTags: Set<String> = ["img", "hr", "br"]
    static let singleBBTags: Set<String> = ["*", "photo", "video"]
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

    func commit(to controller: ParseController, terminator: Character?) -> CharacterHandler {
        guard !name.isEmpty else {
            return DefaultCharacterHandler(firstChar: nil)
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

        return DefaultCharacterHandler(firstChar: nil)
    }

    func nextHandlerWith(terminator: Character?) -> CharacterHandler {
        return DefaultCharacterHandler(firstChar: nil)
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

    func commit(to controller: ParseController, terminator: Character?) -> CharacterHandler {
        guard !name.isEmpty else {
            return DefaultCharacterHandler(firstChar: nil)
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

        return DefaultCharacterHandler(firstChar: nil)
    }
}

private final class DefaultCharacterHandler: CharacterHandler {
    private var string: String = ""
    private var length: Int = 0
    private var hasLineBreak: Bool = false

    init(firstChar: Character?) {
        if let ch = firstChar {
            string.append(ch)

            length += 1
        }
    }

    func accept(character: Character) -> Bool {
        switch character {
        case "[", "<", ":", "&", ";":
            return false
        case "\r", "\n", "\r\n":
            hasLineBreak = true

            return false
        default:
            string.append(character)
            length += 1
        }

        return true
    }

    func commit(to controller: ParseController, terminator: Character?) -> CharacterHandler {
        if string.first == ":", terminator == ":", length < Emoticons.trie.maxKeyLength, let replacement = Emoticons.trie.valueFor(key: string + ":") {
            controller.save(string: replacement)

            return DefaultCharacterHandler(firstChar: nil)
        }

        if string.first == "&", terminator == ";", length < HTMLEntities.trie.maxKeyLength, let replacement = HTMLEntities.trie.valueFor(key: string + ";") {
            controller.save(string: replacement)

            return DefaultCharacterHandler(firstChar: nil)
        }

        if !string.isEmpty {
            controller.save(string: string)
        }

        if hasLineBreak {
            controller.saveLineBreak()
        }

        switch terminator {
        case "[":
            return BBTagCharacterHandler()
        case "<":
            return HTMLTagCharacterHandler()
        case ":", "&", ";":
            return DefaultCharacterHandler(firstChar: terminator)
        default:
            return DefaultCharacterHandler(firstChar: nil)
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
        case lineBreak
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

        var handler: CharacterHandler = DefaultCharacterHandler(firstChar: nil)

        string.forEach { character in
            if handler.accept(character: character) {
                return
            }

            let nextHandler = handler.commit(to: self, terminator: character)

            handler = nextHandler
        }

        _ = handler.commit(to: self, terminator: nil)

        return rootNode
    }

    // MARK: -

    func save(string: String) {
        nodeStack.peek?.children.append(.string(string))
    }

    func saveLineBreak() {
        nodeStack.peek?.children.append(.lineBreak)
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
