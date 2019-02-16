public final class Trie<KeyType: Collection, ValueType> where KeyType.Element: Hashable {
    private final class Node {
        var key: KeyType.Element?
        var value: ValueType?

        init(key: KeyType.Element?) {
            self.key = key
        }

        private var children: [KeyType.Element: Node] = [:]

        subscript(_ key: KeyType.Element) -> Node? {
            get { return children[key] }
            set { children[key] = newValue }
        }

        func makeNode(key: KeyType.Element) -> Node {
            if let node = children[key] {
                return node
            }

            let node = Node(key: key)
            children[key] = node
            return node
        }
    }

    // MARK: -

    private let root = Node(key: nil)

    public init() {}

    // MARK: -

    public private(set) var maxKeyLength: Int = 0

    public func insert(key: KeyType, value: ValueType) {
        var current = root

        for element in key {
            current = current.makeNode(key: element)
        }

        current.value = value

        let keyLength = key.count

        if keyLength > maxKeyLength {
            maxKeyLength = keyLength
        }
    }

    public func hasPathFor(key: KeyType) -> Bool {
        var current = root

        for element in key {
            guard let node = current[element] else {
                return false
            }

            current = node
        }

        return true
    }

    public func valueFor(key: KeyType) -> ValueType? {
        var current = root

        for element in key {
            guard let node = current[element] else {
                return nil
            }

            current = node
        }

        return current.value
    }
}
