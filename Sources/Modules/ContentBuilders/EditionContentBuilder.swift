import Foundation
import UIKit
import ALLKit
import FantLabUtils
import FantLabModels
import FantLabStyle
import FantLabLayoutSpecs
import FantLabText

public final class EditionContentBuilder: ListContentBuilder {
    public typealias ModelType = EditionModel

    // MARK: -

    public init() {}

    // MARK: -

    public var onURLTap: ((URL) -> Void)?

    // MARK: -

    public func makeListItemsFrom(model: EditionModel) -> [ListItem] {
        var listItems: [ListItem] = []

        // хедер

        do {
            listItems.append(ListItem(
                id: "edition_header",
                layoutSpec: EditionHeaderLayoutSpec(model: model)
            ))

            listItems.append(ListItem(
                id: "edition_header_sep",
                layoutSpec: EmptySpaceLayoutSpec(model: (Colors.perfectGray, 8))
            ))
        }

        // свойства

        do {
            listItems.append(ListItem(
                id: "edition_properties",
                layoutSpec: EditionPropertiesLayoutSpec(model: model)
            ))
        }

        // описание

        do {
            let string = ([model.description] + model.content + [model.notes, model.planDescription]).compactAndJoin("\n\n")

            let text = FLText(
                string: string,
                decorator: TextStyle.defaultTextDecorator,
                setupLinkAttribute: true
            )

            listItems.append(ListItem(
                id: "edition_text_sep",
                layoutSpec: EmptySpaceLayoutSpec(model: (Colors.perfectGray, 8))
            ))

            listItems.append(ListItem(
                id: "edition_text_spacing",
                layoutSpec: EmptySpaceLayoutSpec(model: (UIColor.white, 16))
            ))

            let items = text.items.enumerated().flatMap { (index, textItem) -> [ListItem] in
                guard case let .string(content) = textItem else {
                    return []
                }

                let model = FLTextStringLayoutModel(
                    string: content,
                    linkAttributes: text.decorator.linkAttributes,
                    openURL: ({ [weak self] url in
                        self?.onURLTap?(url)
                    })
                )

                let itemId = "edition_text_\(index)"

                let contentItem = ListItem(
                    id: itemId,
                    layoutSpec: FLTextStringLayoutSpec(model: model)
                )

                let sepItem = ListItem(
                    id: itemId + "_sep",
                    layoutSpec: EmptySpaceLayoutSpec(model: (UIColor.white, 16))
                )

                return [contentItem, sepItem]
            }

            listItems.append(contentsOf: items)
        }

        return listItems
    }
}
