final class FLText {
    typealias NodeRange = (node: FLTagNode, range: Range<String.Index>)

    var string: String = ""
    var nodeRanges: [NodeRange] = []
}

final class FLTextBuilder {
    static func makeTextFrom(node: FLTagNode, replacementRules: [String: String]) -> FLText {
        let text = FLText()
        traverse(node: node, text: text, replacementRules: replacementRules)
        return text
    }

    private static func traverse(node: FLTagNode, text: FLText, replacementRules: [String: String]) {
        let startIndex = text.string.endIndex

        if let placeholderText = replacementRules[node.tag.name] {
            text.string.append(placeholderText)
        } else {
            node.children.forEach { child in
                switch child {
                case .string(let string):
                    text.string.append(string)
                case .node(let node):
                    traverse(node: node, text: text, replacementRules: replacementRules)
                }
            }
        }

        let endIndex = text.string.endIndex

        text.nodeRanges.append((node, startIndex..<endIndex))
    }
}
