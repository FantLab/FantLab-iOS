import FantLabModels

final class WorkContentTreeNode {
    let id: Int
    let level: Int
    let model: WorkModel.ChildWorkModel?

    init(id: Int, level: Int, model: WorkModel.ChildWorkModel?) {
        self.id = id
        self.level = level
        self.model = model
    }

    // MARK: -

    private(set) weak var parent: WorkContentTreeNode?
    private(set) var children: [WorkContentTreeNode] = []

    func add(child node: WorkContentTreeNode) {
        node.parent = self
        children.append(node)

        node.traverseParents {
            $0.count += 1
        }
    }

    func traverseParents(using closure: (WorkContentTreeNode) -> Void) {
        var cursor: WorkContentTreeNode? = parent

        while let node = cursor {
            closure(node)

            cursor = cursor?.parent
        }
    }

    // MARK: -

    private(set) var count: Int = 0
    var isExpanded: Bool = false

    // MARK: -

    func traverseContent(using closure: (WorkContentTreeNode) -> Void) {
        closure(self)

        guard isExpanded else {
            return
        }

        children.forEach {
            $0.traverseContent(using: closure)
        }
    }
}
