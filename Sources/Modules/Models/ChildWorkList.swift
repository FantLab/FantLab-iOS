public final class ChildWorkList {
    public let items: [ChildWorkModel]

    public init(_ items: [ChildWorkModel]) {
        self.items = items
    }

    public func makeWorkTree() -> WorkTreeNode {
        let rootNode = WorkTreeNode(id: 0, level: 0, model: nil)

        var head: WorkTreeNode = rootNode

        items.enumerated().forEach { (index, model) in
            let node = WorkTreeNode(id: index + 1, level: model.deepLevel, model: model)
            node.isExpanded = false

            if node.level == head.level {
                head.parent?.add(child: node)
            } else {
                while node.level <= head.level {
                    head = head.parent ?? rootNode
                }

                head.add(child: node)
            }

            head = node
        }

        rootNode.isExpanded = true

        return rootNode
    }
}
