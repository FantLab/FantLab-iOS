import Foundation
import UIKit
import ALLKit
import FLKit
import FLModels
import FLStyle
import FLLayoutSpecs
import FLText

public final class EditionListContentBuilder: ListContentBuilder {
    public typealias ModelType = [EditionBlockModel]

    // MARK: -

    public init() {}

    // MARK: -

    public var onEditionTap: ((Int) -> Void)?

    // MARK: -

    public func makeListItemsFrom(model: [EditionBlockModel]) -> [ListItem] {
        var items: [ListItem] = []

        let columnsCount = 3

        model.enumerated().forEach { (i, block) in
            let count = block.list.count

            let titleItem = ListItem(
                id: "edition_block_\(i)_title",
                layoutSpec: EditionsBlockTitleLayoutSpec(model: EditionsBlockTitleLayoutModel(
                    title: block.title,
                    count: count
                ))
            )

            items.append(titleItem)

            block.list.enumerated().forEach({ (j, edition) in
                let item = ListItem(
                    id: "edition_block_\(i)_edition_\(j)",
                    layoutSpec: EditionPreviewLayoutSpec(model: edition)
                )

                item.sizeConstraintsModifier = { sc in
                    guard let width = sc.width else {
                        return sc
                    }

                    return SizeConstraints(width: (width / CGFloat(columnsCount)).rounded(.down), height: (width / CGFloat(columnsCount - 1)).rounded(.down))
                }

                item.didSelect = { [weak self] (view, _) in
                    view.animated(action: {
                        self?.onEditionTap?(edition.id)
                    })
                }

                items.append(item)
            })

            let remainder = count % columnsCount

            if remainder > 0 {
                (0..<columnsCount - remainder).forEach({ j in
                    let item = ListItem(
                        id: "edition_block_\(i)_edition_\(j)_placeholder",
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
                id: "edition_block_\(i)_sep",
                layoutSpec: EmptySpaceLayoutSpec(model: (Colors.sectionSeparatorColor, 12))
            )

            items.append(sepItem)
        }

        items.removeLast()

        return items
    }
}
