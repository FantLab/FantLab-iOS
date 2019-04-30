import Foundation
import UIKit
import ALLKit
import FLKit
import FLModels
import FLLayoutSpecs
import FLStyle
import FLText

public final class PubNewsContentBuilder: ListContentBuilder {
    public typealias ModelType = [PubNewsModel]

    // MARK: -

    public init() {}

    public var onEditionTap: ((Int) -> Void)?
    public var onURLTap: ((URL) -> Void)?

    // MARK: -

    public func makeListItemsFrom(model: [PubNewsModel]) -> [ListItem] {
        var items: [ListItem] = []

        let textDecorator = TextStyle.makeDecoratorWithFontSize(15, lineSpacing: 3, paragraphSpacing: 4)

        model.forEach { edition in
            let itemId = "edition_" + String(edition.editionId)

            let item = ListItem(
                id: itemId,
                layoutSpec: PubNewsLayoutSpec(model: edition)
            )

            item.didTap = { [weak self] (view, _) in
                view.animated(action: {
                    self?.onEditionTap?(edition.editionId)
                })
            }

            items.append(item)

            if !edition.info.isEmpty {
                let descriptionText = FLText(
                    string: edition.info,
                    decorator: textDecorator,
                    setupLinkAttribute: true
                )

                if !descriptionText.items.isEmpty {
                    items.append(ListItem(
                        id: itemId + "_description",
                        layoutSpec: FLComboTextLayoutSpec(model: FLComboTextLayoutModel(text: descriptionText, openURL: { [weak self] url in
                            self?.onURLTap?(url)
                        }))
                    ))
                }
            }

            items.append(ListItem(
                id: itemId + "_sep",
                layoutSpec: EmptySpaceLayoutSpec(model: (Colors.perfectGray, 8))
            ))
        }

        return items
    }
}
