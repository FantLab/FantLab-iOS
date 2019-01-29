import Foundation
import UIKit
import ALLKit
import FantLabBaseUI
import FantLabModels
import FantLabLayoutSpecs
import FantLabStyle
import FantLabWebAPI
import FantLabUtils

final class EditionListViewController: ListViewController {
    private let editionBlocks: [EditionBlockModel]

    init(editionBlocks: [EditionBlockModel]) {
        self.editionBlocks = editionBlocks

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Все издания"

        DispatchQueue.global().async { [weak self] in
            let items = self?.makeListItems() ?? []

            DispatchQueue.main.async {
                self?.adapter.set(items: items)
            }
        }
    }

    private func makeListItems() -> [ListItem] {
        var items: [ListItem] = []

        let columnsCount = 3

        editionBlocks.enumerated().forEach { (i, block) in
            let count = block.list.count

            let titleItem = ListItem(
                id: "\(i)_title",
                layoutSpec: EditionsBlockTitleLayoutSpec(model: EditionsBlockTitleLayoutModel(
                    title: block.title,
                    count: count
                ))
            )

            items.append(titleItem)

            block.list.enumerated().forEach({ (j, edition) in
                let item = ListItem(
                    id: "\(i)_\(j)",
                    layoutSpec: EditionPreviewLayoutSpec(model: edition)
                )

                item.sizeConstraintsModifier = { sc in
                    guard let width = sc.width else {
                        return sc
                    }

                    return SizeConstraints(width: (width / CGFloat(columnsCount)).rounded(.down), height: (width / CGFloat(columnsCount - 1)).rounded(.down))
                }

                item.didSelect = { [weak self] (cell, _) in
                    CellSelection.scale(cell: cell, action: {
                        self?.open(edition: edition.id)
                    })
                }

                items.append(item)
            })

            let remainder = count % columnsCount

            if remainder > 0 {
                (0..<columnsCount - remainder).forEach({ j in
                    let item = ListItem(
                        id: "\(i)_\(j)_",
                        layoutSpec: EmptyLayoutSpec()
                    )

                    item.sizeConstraintsModifier = { sc in
                        guard let width = sc.width else {
                            return sc
                        }

                        return SizeConstraints(width: (width / CGFloat(columnsCount)).rounded(.down), height: (width / CGFloat(columnsCount - 1)).rounded(.down))
                    }

                    items.append(item)
                })
            }

            let sepItem = ListItem(
                id: "\(i)_sep",
                layoutSpec: EmptySpaceLayoutSpec(model: (Colors.perfectGray, 12))
            )

            items.append(sepItem)
        }

        items.removeLast()

        return items
    }

    private func open(edition id: Int) {
        let vc = EditionViewController(editionId: id)

        navigationController?.pushViewController(vc, animated: true)
    }
}
