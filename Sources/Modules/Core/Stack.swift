public struct Stack<T> {
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

    public private(set) var count: Int = 0

    public mutating func push(_ value: T) {
        let node = Node(value)
        node.prev = top
        top = node

        count += 1
    }

    @discardableResult
    public mutating func pop() -> T? {
        defer {
            top = top?.prev

            if count > 0 {
                count -= 1
            }
        }

        return peek
    }

    public var peek: T? {
        return top?.value
    }
}
