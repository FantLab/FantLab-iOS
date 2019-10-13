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
        let canRetry = ErrorHelper.isNetwork(error: model)
        let image = UIImage(named: canRetry ? "retry" : "error")!
        let errorText = ErrorHelper.makeHumanReadableTextFrom(error: model)

        let item = ListItem(
            id: errorText,
            layoutSpec: ErrorDescriptionLayoutSpec(model: (image, errorText))
        )

        if canRetry {
            item.didTap = { [weak self] (view, _) in
                view.animated(action: {
                    self?.onRetry?()
                })
            }
        }

        return [item]
    }
}
