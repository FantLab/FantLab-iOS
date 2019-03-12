import Foundation
import UIKit
import ALLKit
import FLStyle
import FLKit
import FLLayoutSpecs

public final class ErrorContentBuilder: ListContentBuilder {
    public typealias ModelType = Error

    public var onRetry: (() -> Void)?

    private let errorId = UUID().uuidString

    public func makeListItemsFrom(model: Error) -> [ListItem] {
        let errorText = ErrorHelper.makeHumanReadableTextFrom(error: model)
        let canRetry = ErrorHelper.isNetwork(error: model)

        let item = ListItem(
            id: errorId,
            model: errorText,
            layoutSpec: ErrorDescriptionLayoutSpec(model: (errorText, canRetry))
        )

        if canRetry {
            item.didSelect = { [weak self] (view, _) in
                view.animated(action: {
                    self?.onRetry?()
                })
            }
        }

        return [item]
    }
}
