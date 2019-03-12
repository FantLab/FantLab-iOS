import Foundation
import UIKit
import ALLKit
import FLKit
import FLModels
import FLLayoutSpecs
import FLStyle

public final class UserProfileContentBuilder: ListContentBuilder {
    public typealias ModelType = UserProfileModel

    // MARK: -

    public init() {}

    // MARK: -

    public var onReviewsTap: ((Int, Int) -> Void)?

    // MARK: -

    public func makeListItemsFrom(model: UserProfileModel) -> [ListItem] {
        var items: [ListItem] = []

        // header

        do {
            items.append(ListItem(
                id: "profile_header",
                layoutSpec: UserProfileHeaderLayoutSpec(model: model)
            ))
        }

        // properties

        do {
            items.append(ListItem(
                id: "profile_properties_sep",
                layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
            ))

            items.append(ListItem(
                id: "profile_properties",
                layoutSpec: ObjectPropertiesLayoutSpec(model: model)
            ))
        }

        // reviews

        if model.reviewsCount > 0 {
            items.append(ListItem(
                id: "profile_reviews_sep",
                layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
            ))

            let item = ListItem(
                id: "profile_reviews",
                layoutSpec: ShowAllButtonLayoutSpec(model: "Отзывы (\(model.reviewsCount))")
            )

            item.didSelect = { [weak self] (view, _) in
                view.animated(action: {
                    self?.onReviewsTap?(model.id, model.reviewsCount)
                })
            }

            items.append(item)
        }

        return items
    }
}
