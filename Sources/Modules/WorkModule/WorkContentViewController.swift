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

    // MARK: -

    private let workModel: WorkModel
    private let router: WorkModuleRouter

    init(workModel: WorkModel, router: WorkModuleRouter) {
        self.workModel = workModel
        self.router = router

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Содержание"

        let rootNode = makeContentTreeFrom(work: workModel)

        buildUIFrom(rootNode: rootNode)
    }

    private func buildUIFrom(rootNode: WorkContentTreeNode) {
        var items: [ListItem] = []

        rootNode.traverseContent { node in
            guard let work = node.model else {
                return
            }

            let itemModel = ListItemModel(
                id: node.id,
                isExpanded: node.isExpanded
            )

            let layoutModel = ChildWorkModelLayoutModel(
                work: work,
                count: node.count,
                isExpanded: node.isExpanded,
                expandCollapseAction: node.count > 0 ? ({ [weak self] in
                    node.isExpanded = !node.isExpanded

                    self?.buildUIFrom(rootNode: rootNode)
                }) : nil
            )

            let item = ListItem(
                id: String(itemModel.id),
                model: itemModel,
                layoutSpec: ChildWorkModelLayoutSpec(model: layoutModel)
            )

            if work.id > 0 {
                item.actions.onSelect = { [weak self] in
                    self?.router.openWork(id: work.id)
                }
            }

            items.append(item)

            items.append(ListItem(id: String(itemModel.id) + "_sep", layoutSpec: ItemSeparatorLayoutSpec()))
        }

        adapter.set(items: items)
    }

    private func makeContentTreeFrom(work workModel: WorkModel) -> WorkContentTreeNode {
        let rootNode = WorkContentTreeNode(id: 0, level: 0, model: nil)
        rootNode.isExpanded = true

        var head: WorkContentTreeNode = rootNode

        workModel.children.enumerated().forEach { (index, model) in
            let node = WorkContentTreeNode(id: index + 1, level: model.deepLevel, model: model)
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
