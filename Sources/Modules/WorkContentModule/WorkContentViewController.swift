import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabSharedUI
import FantLabUtils

final class WorkContentViewController: ListViewController {
    private struct ListItemModel: Equatable {
        let id: Int
        let isExpanded: Bool
    }

    private typealias CollapseAction = () -> Void

    // MARK: -

    private let workModel: WorkModel
    private weak var router: WorkContentModuleRouter?

    init(workModel: WorkModel, router: WorkContentModuleRouter) {
        self.workModel = workModel
        self.router = router

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: -

    private var backStack = Stack<CollapseAction>() {
        didSet {
            canCollapse = backStack.count > 0
        }
    }

    private var canCollapse: Bool = false {
        didSet {
            guard canCollapse != oldValue else {
                return
            }

            if canCollapse {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Свернуть", style: .plain, target: self, action: #selector(collapse))
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        }
    }

    @objc
    private func collapse() {
        backStack.pop()?()
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Содержание"

        guard let rootNode = makeContentTreeFrom(work: workModel) else {
            return
        }

        buildUIFrom(rootNode: rootNode)
    }

    private func buildUIFrom(rootNode: WorkContentTreeNode) {
        var items: [ListItem] = []

        rootNode.traverseContent { node in
            guard let work = node.model else {
                return
            }

            let itemModel = ListItemModel(id: node.id, isExpanded: node.isExpanded)

            let item = ListItem(
                id: String(itemModel.id),
                model: itemModel,
                layoutSpec: WorkContentTreeNodeLayoutSpec(model: node)
            )

            if !node.isExpanded && node.count > 0 {
                item.actions.onSelect = { [weak self] in
                    node.isExpanded = true

                    self?.buildUIFrom(rootNode: rootNode)

                    self?.backStack.push {
                        node.isExpanded = false

                        self?.buildUIFrom(rootNode: rootNode)
                    }
                }
            } else if work.id > 0 {
                item.actions.onSelect = { [weak self] in
                    self?.router?.openWork(workId: work.id)
                }
            }

            items.append(item)
        }

        adapter.set(items: items)
    }

    private func makeContentTreeFrom(work model: WorkModel) -> WorkContentTreeNode? {
        guard !model.children.isEmpty else {
            return nil
        }

        let rootNode = WorkContentTreeNode(id: 0, level: 0, model: nil)
        rootNode.isExpanded = true

        var head: WorkContentTreeNode = rootNode

        workModel.children.enumerated().forEach { (index, model) in
            let node = WorkContentTreeNode(id: index + 1, level: model.deepLevel, model: model)

            if node.level == head.level {
                head.parent?.add(child: node)

                return
            }

            while node.level <= head.level {
                head = head.parent ?? rootNode
            }

            head.add(child: node)
            head = node
        }

        return rootNode
    }
}
