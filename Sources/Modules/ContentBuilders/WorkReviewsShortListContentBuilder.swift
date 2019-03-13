import Foundation
import UIKit
import ALLKit
import FLKit
import FLModels
import FLStyle
import FLLayoutSpecs

public struct WorkReviewsShortListViewState {
    public let work: WorkModel
    public let reviews: [WorkReviewModel]
    public let hasShowAllButton: Bool

    public init(work: WorkModel,
                reviews: [WorkReviewModel],
                hasShowAllButton: Bool) {

        self.work = work
        self.reviews = reviews
        self.hasShowAllButton = hasShowAllButton
    }
}

public final class WorkReviewsShortListContentBuilder: ListContentBuilder {
    public typealias ModelType = WorkReviewsShortListViewState

    // MARK: -

    let singleReviewContentBuilder = WorkReviewContentBuilder(headerMode: .user)

    var onShowAllReviewsTap: ((WorkModel) -> Void)?

    // MARK: -

    public func makeListItemsFrom(model: WorkReviewsShortListViewState) -> [ListItem] {
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

            item.didTap = { [weak self] view, _ in
                view.animated(action: {
                    self?.onShowAllReviewsTap?(model.work)
                })
            }

            items.append(item)
        }

        return items
    }
}
