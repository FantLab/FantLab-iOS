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

    let singleReviewContentBuilder = WorkReviewContentBuilder(headerMode: .user)

    var onShowAllReviewsTap: ((WorkModel) -> Void)?

    // MARK: -

    public func makeListItemsFrom(model: WorkReviewsShortListContentModel) -> [ListItem] {
        var items: [ListItem] = []

        model.reviews.forEach { review in
            items.append(contentsOf: singleReviewContentBuilder.makeListItemsFrom(model: review))

            items.append(ListItem(
                id: "review_\(review.id)_sep",
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
