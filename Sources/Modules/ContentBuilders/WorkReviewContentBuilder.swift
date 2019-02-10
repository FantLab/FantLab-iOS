import Foundation
import UIKit
import ALLKit
import FantLabUtils
import FantLabModels
import FantLabLayoutSpecs
import FantLabStyle

public enum WorkReviewHeaderMode {
    case user
    case work
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
                id: "review_\(model.id)_user_header",
                layoutSpec: WorkReviewUserHeaderLayoutSpec(model: model)
            )

            let onTap = onReviewUserTap

            item.didSelect = { (cell, _) in
                CellSelection.scale(cell: cell, action: {
                    onTap?(model.user.id)
                })
            }

            items.append(item)
        case .work:
            let item = ListItem(
                id: "review_\(model.id)_work_header",
                layoutSpec: WorkReviewWorkHeaderLayoutSpec(model: model)
            )

            let onTap = onReviewWorkTap

            item.didSelect = { (cell, _) in
                CellSelection.scale(cell: cell, action: {
                    onTap?(model.work.id)
                })
            }

            items.append(item)
        }

        if showText {
            let item = ListItem(
                id: "review_\(model.id)_text",
                layoutSpec: WorkReviewTextLayoutSpec(model: model)
            )

            item.didSelect = { [weak self] (cell, _) in
                CellSelection.scale(cell: cell, action: {
                    self?.onReviewTextTap?(model)
                })
            }

            items.append(item)
        }

        return items
    }
}
