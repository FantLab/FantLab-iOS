import Foundation
import UIKit
import ALLKit
import FantLabUtils
import FantLabModels
import FantLabStyle
import FantLabLayoutSpecs

public typealias WorkReviewsListContentModel = (reviews: [WorkReviewModel], state: DataState<Void>)

public final class WorkReviewsListContentBuilder: ListContentBuilder {
    public typealias ModelType = WorkReviewsListContentModel

    // MARK: -

    public init(headerMode: WorkReviewHeaderMode) {
        singleReviewContentBuilder = WorkReviewContentBuilder(headerMode: headerMode)
    }

    public let stateContentBuilder = DataStateContentBuilder(dataContentBuilder: EmptyContentBuilder())
    public let singleReviewContentBuilder: WorkReviewContentBuilder

    // MARK: -

    public var onLastItemDisplay: (() -> Void)?

    // MARK: -

    private let loadingId = UUID().uuidString
    private let errorId = UUID().uuidString

    // MARK: -

    public func makeListItemsFrom(model: WorkReviewsListContentModel) -> [ListItem] {
        var items: [ListItem] = model.reviews.enumerated().flatMap { (index, review) -> [ListItem] in
            var reviewItems = singleReviewContentBuilder.makeListItemsFrom(model: review)

            let sepItem = ListItem(
                id: "review_\(review.id)" + "_sep",
                layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
            )

            if index == model.reviews.endIndex - 1 {
                sepItem.willDisplay = { [weak self] _, _ in
                    self?.onLastItemDisplay?()
                }
            }

            reviewItems.append(sepItem)

            return reviewItems
        }

        items.append(contentsOf: stateContentBuilder.makeListItemsFrom(model: model.state))

        return items
    }
}
