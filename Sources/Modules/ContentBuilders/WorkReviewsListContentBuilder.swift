import Foundation
import UIKit
import ALLKit
import FLKit
import FLModels
import FLStyle
import FLLayoutSpecs

public struct WorkReviewsListViewState {
    public var reviews: [WorkReviewModel]
    public var state: DataState<Void>

    public init(reviews: [WorkReviewModel],
                state: DataState<Void>) {

        self.reviews = reviews
        self.state = state
    }
}

public final class WorkReviewsListContentBuilder: ListContentBuilder {
    public typealias ModelType = WorkReviewsListViewState

    // MARK: -

    private let useSectionSeparatorStyle: Bool

    public init(headerMode: WorkReviewHeaderMode, useSectionSeparatorStyle: Bool = false) {
        self.useSectionSeparatorStyle = useSectionSeparatorStyle

        singleReviewContentBuilder = WorkReviewContentBuilder(headerMode: headerMode)
    }

    public let stateContentBuilder = DataStateContentBuilder(dataContentBuilder: EmptyContentBuilder())
    public let singleReviewContentBuilder: WorkReviewContentBuilder

    public var onLastItemDisplay: (() -> Void)?

    // MARK: -

    private let loadingId = UUID().uuidString
    private let errorId = UUID().uuidString

    // MARK: -

    public func makeListItemsFrom(model: WorkReviewsListViewState) -> [ListItem] {
        var items: [ListItem] = model.reviews.flatMap { review -> [ListItem] in
            var reviewItems = singleReviewContentBuilder.makeListItemsFrom(model: review)

            let sepSpec: LayoutSpec = useSectionSeparatorStyle ? EmptySpaceLayoutSpec(model: (Colors.perfectGray, 8)) : ItemSeparatorLayoutSpec(model: Colors.separatorColor)

            reviewItems.append(ListItem(
                id: "review_\(review.id)_sep",
                layoutSpec: sepSpec
            ))

            return reviewItems
        }

        items.last?.willShow = { [weak self] _, _ in
            self?.onLastItemDisplay?()
        }

        items.append(contentsOf: stateContentBuilder.makeListItemsFrom(model: model.state))

        return items
    }
}
