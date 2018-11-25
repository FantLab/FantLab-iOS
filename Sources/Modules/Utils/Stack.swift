public final class Stack<T> {
    private final class Node {
        let value: T

        init(_ value: T) {
            self.value = value
        }

        var prev: Node?
    }

    // MARK: -

    private var top: Node?

    public init() {}

    // MARK: -

    public func push(_ value: T) {
        let node = Node(value)
        node.prev = top
        top = node
    }

    @discardableResult
    public func pop() -> T? {
        defer { top = top?.prev }
        return peek
    }

    public var peek: T? {
        return top?.value
    }
}
