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

    public init() {}

    // MARK: -

    public var onReviewTap: ((WorkReviewModel) -> Void)?
    public var onLastItemDisplay: (() -> Void)?

    // MARK: -

    private let loadingId = UUID().uuidString
    private let errorId = UUID().uuidString

    // MARK: -

    public func makeListItemsFrom(model: WorkReviewsListContentModel) -> [ListItem] {
        var items: [ListItem] = model.reviews.enumerated().flatMap { (index, review) -> [ListItem] in
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

            if index == model.reviews.endIndex - 1 {
                textItem.willDisplay = { [weak self] _, _ in
                    self?.onLastItemDisplay?()
                }
            }

            let separatorItem = ListItem(
                id: itemId + "_separator",
                layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
            )

            return [headerItem, textItem, separatorItem]
        }

        switch model.state {
        case .loading:
            let item = ListItem(id: loadingId, model: loadingId, layoutSpec: SpinnerLayoutSpec())

            items.append(item)
        case let .error(error):
        break // TODO:
        case .initial, .idle:
            break
        }

        return items
    }
}
