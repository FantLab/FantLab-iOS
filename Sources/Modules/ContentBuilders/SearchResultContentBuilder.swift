import Foundation
import UIKit
import ALLKit
import FantLabUtils
import FantLabModels
import FantLabStyle
import FantLabLayoutSpecs

public typealias SearchResultContentModel = (authors: [AuthorPreviewModel], works: [WorkPreviewModel])

public final class SearchResultContentBuilder: ListContentBuilder {
    public typealias ModelType = SearchResultContentModel

    // MARK: -

    public init() {}

    // MARK: -

    public var onAuthorTap: ((Int) -> Void)?
    public var onWorkTap: ((Int) -> Void)?

    // MARK: -

    public func makeListItemsFrom(model: SearchResultContentModel) -> [ListItem] {
        var items: [ListItem] = []

        model.authors.forEach { author in
            let item = ListItem(
                id: "author_\(author.id)",
                layoutSpec: AuthorPreviewLayoutSpec(model: author)
            )

            item.didSelect = { [weak self] cell, _ in
                CellSelection.scale(cell: cell, action: {
                    self?.onAuthorTap?(author.id)
                })
            }

            items.append(item)

            items.append(ListItem(
                id: "author_\(author.id)_sep",
                layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
            ))
        }

        if !model.authors.isEmpty && !model.works.isEmpty {
            items.removeLast()

            items.append(ListItem(
                id: "authors_works_sep",
                layoutSpec: EmptySpaceLayoutSpec(model: (Colors.perfectGray, 8))
            ))
        }

        model.works.forEach { work in
            let item = ListItem(
                id: "work_\(work.id)",
                layoutSpec: WorkPreviewLayoutSpec(model: work)
            )

            item.didSelect = { [weak self] cell, _ in
                CellSelection.scale(cell: cell, action: {
                    self?.onWorkTap?(work.id)
                })
            }

            items.append(item)

            items.append(ListItem(
                id: "work_\(work.id)_sep",
                layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
            ))
        }

        return items
    }
}
