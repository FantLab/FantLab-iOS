public final class WorkTreeNode: CustomDebugStringConvertible {
    public let id: Int
    public let level: Int
    public let model: ChildWorkModel?

    public init(id: Int, level: Int, model: ChildWorkModel?) {
        self.id = id
        self.level = level
        self.model = model
    }

    // MARK: -

    public private(set) weak var parent: WorkTreeNode?
    public private(set) var children: [WorkTreeNode] = []

    public func add(child node: WorkTreeNode) {
        node.parent = self
        children.append(node)

        node.traverseParents {
            $0.count += 1
        }
    }

    public func traverseParents(using closure: (WorkTreeNode) -> Void) {
        var cursor: WorkTreeNode? = parent

        while let node = cursor {
            closure(node)

            cursor = cursor?.parent
        }
    }

    // MARK: -

    public private(set) var count: Int = 0
    public var isExpanded: Bool = false

    // MARK: -

    public func traverseContent(using closure: (WorkTreeNode) -> Void) {
        closure(self)

        guard isExpanded else {
            return
        }

        children.forEach {
            $0.traverseContent(using: closure)
        }
    }

    private func traverse(using closure: (WorkTreeNode) -> Void) {
        closure(self)

        children.forEach {
            $0.traverse(using: closure)
        }
    }

    // MARK: -

    public var debugDescription: String {
        var result = ""

        traverse { node in
            var name = node.model?.name ?? ""

            if name.isEmpty {
                name = node.model?.origName ?? ""
            }

            result.append(String(repeating: "    ", count: node.level))
            result.append(name.isEmpty ? "-" : name)
            result.append("\n")
        }

        return result
    }
}
