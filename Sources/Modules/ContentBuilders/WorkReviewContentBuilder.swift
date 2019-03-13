import Foundation
import UIKit
import ALLKit
import FLKit
import FLModels
import FLLayoutSpecs
import FLStyle

public enum WorkReviewHeaderMode {
    case user
    case work
    case userAndWork
}

public final class WorkReviewContentBuilder: ListContentBuilder {
    public typealias ModelType = WorkReviewModel

    // MARK: -

    public let headerMode: WorkReviewHeaderMode
    public let showText: Bool

    public init(headerMode: WorkReviewHeaderMode, showText: Bool = true) {
        self.headerMode = headerMode
        self.showText = showText
    }

    // MARK: -

    public var onReviewUserTap: ((Int) -> Void)?
    public var onReviewWorkTap: ((Int) -> Void)?
    public var onReviewTextTap: ((WorkReviewModel) -> Void)?

    // MARK: -

    public func makeListItemsFrom(model: WorkReviewModel) -> [ListItem] {
        var items: [ListItem] = []

        switch headerMode {
        case .user:
            let item = ListItem(
                id: "review_\(model.id)_user_header_\(model.votes)",
                layoutSpec: WorkReviewUserHeaderLayoutSpec(model: model)
            )

            let onTap = onReviewUserTap

            item.didTap = { (view, _) in
                view.animated(action: {
                    onTap?(model.user.id)
                })
            }

            items.append(item)
        case .work:
            let item = ListItem(
                id: "review_\(model.id)_work_header_\(model.votes)",
                layoutSpec: WorkReviewWorkHeaderLayoutSpec(model: model)
            )

            let onTap = onReviewWorkTap

            item.didTap = { (view, _) in
                view.animated(action: {
                    onTap?(model.work.id)
                })
            }

            items.append(item)
        case .userAndWork:
            do {
                let item = ListItem(
                    id: "review_\(model.id)_user_header_\(model.votes)",
                    layoutSpec: WorkReviewUserHeaderLayoutSpec(model: model)
                )

                let onTap = onReviewUserTap

                item.didTap = { (view, _) in
                    view.animated(action: {
                        onTap?(model.user.id)
                    })
                }

                items.append(item)
            }

            do {
                let item = ListItem(
                    id: "review_\(model.id)_work_short_header_\(model.votes)",
                    layoutSpec: WorkReviewWorkShortHeaderLayoutSpec(model: model)
                )

                let onTap = onReviewWorkTap

                item.didTap = { (view, _) in
                    view.animated(action: {
                        onTap?(model.work.id)
                    })
                }

                items.append(item)
            }
        }

        if showText {
            let item = ListItem(
                id: "review_\(model.id)_text",
                layoutSpec: WorkReviewTextLayoutSpec(model: model)
            )

            item.didTap = { [weak self] (view, _) in
                view.animated(action: {
                    self?.onReviewTextTap?(model)
                })
            }

            items.append(item)
        }

        return items
    }
}
