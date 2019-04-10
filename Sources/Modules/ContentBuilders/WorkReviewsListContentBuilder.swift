import Foundation
import UIKit
import ALLKit
import FLKit
import FLModels
import FLStyle
import FLLayoutSpecs

public final class WorkReviewsListContentBuilder: ListContentBuilder {
    public typealias ModelType = [WorkReviewModel]

    // MARK: -

    private let useSectionSeparatorStyle: Bool

    public init(headerMode: WorkReviewHeaderMode, useSectionSeparatorStyle: Bool = false) {
        self.useSectionSeparatorStyle = useSectionSeparatorStyle

        singleReviewContentBuilder = WorkReviewContentBuilder(headerMode: headerMode)
    }

    public let singleReviewContentBuilder: WorkReviewContentBuilder

    // MARK: -

    public func makeListItemsFrom(model: [WorkReviewModel]) -> [ListItem] {
        return model.flatMap { review -> [ListItem] in
            var reviewItems = singleReviewContentBuilder.makeListItemsFrom(model: review)

            let sepSpec: LayoutSpec = useSectionSeparatorStyle ? EmptySpaceLayoutSpec(model: (Colors.perfectGray, 8)) : ItemSeparatorLayoutSpec(model: Colors.separatorColor)

            reviewItems.append(ListItem(
                id: "review_\(review.id)_sep",
                layoutSpec: sepSpec
            ))

            return reviewItems
        }
    }
}
