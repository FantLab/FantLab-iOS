import Foundation
import UIKit
import ALLKit
import FantLabUtils
import FantLabModels
import FantLabStyle
import FantLabLayoutSpecs

public typealias WorkReviewsShortListContentModel = (work: WorkModel, reviews: [WorkReviewModel], hasShowAllButton: Bool)

public final class WorkReviewsShortListContentBuilder: ListContentBuilder {
    public typealias ModelType = WorkReviewsShortListContentModel

    // MARK: -

    var onReviewTap: ((WorkReviewModel) -> Void)?
    var onShowAllReviewsTap: ((WorkModel) -> Void)?

    // MARK: -

    public func makeListItemsFrom(model: WorkReviewsShortListContentModel) -> [ListItem] {
        var items: [ListItem] = []

        model.reviews.forEach { review in
            let itemId = "review_" + String(review.id)

            let headerItem = ListItem(
                id: itemId + "_header",
                layoutSpec: WorkReviewHeaderLayoutSpec(model: review)
            )

            let textItem = ListItem(
                id: itemId + "_text",
                layoutSpec: WorkReviewTextLayoutSpec(model: review)
            )

            textItem.didSelect = { [weak self] cell, _ in
                CellSelection.scale(cell: cell, action: {
                    self?.onReviewTap?(review)
                })
            }

            items.append(headerItem)
            items.append(textItem)

            items.append(ListItem(
                id: itemId + "_separator",
                layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
            ))
        }

        if model.hasShowAllButton {
            let item = ListItem(
                id: "reviews_show_all_btn",
                layoutSpec: ShowAllButtonLayoutSpec(model: "Все отзывы")
            )

            item.didSelect = { [weak self] cell, _ in
                CellSelection.scale(cell: cell, action: {
                    self?.onShowAllReviewsTap?(model.work)
                })
            }

            items.append(item)
        }

        return items
    }
}
