import Foundation
import UIKit
import ALLKit
import FLKit
import FLModels
import FLStyle
import FLLayoutSpecs
import FLText

public struct TextListViewState {
    public let text: FLText
    public let expandedTextIndices: Set<Int>
    public let images: Dictionary<Int, UIImage>
    public let customHeaderItems: [ListItem]

    public init(text: FLText,
                expandedTextIndices: Set<Int>,
                images: Dictionary<Int, UIImage>,
                customHeaderItems: [ListItem]) {

        self.text = text
        self.expandedTextIndices = expandedTextIndices
        self.images = images
        self.customHeaderItems = customHeaderItems
    }
}

public protocol TextListContentBuilderDelegate: class {
    func makeURLFrom(photoIndex: Int) -> URL?
    func open(url: URL)
    func showHiddenText(index: Int)
    func save(image: UIImage, at index: Int)
}

public final class TextListContentBuilder: ListContentBuilder {
    public typealias ModelType = TextListViewState

    // MARK: -

    public init() {}

    public weak var delegate: TextListContentBuilderDelegate?

    // MARK: -

    public func makeListItemsFrom(model: TextListViewState) -> [ListItem] {
        var items: [ListItem] = model.customHeaderItems

        items.append(ListItem(
            id: "text_items_header_space",
            layoutSpec: EmptySpaceLayoutSpec(model: (UIColor.white, 16))
        ))

        model.text.items.enumerated().forEach { (index, item) in
            let itemId = "text_item_\(index)"

            switch item {
            case let .string(string):
                let item = ListItem(
                    id: itemId,
                    layoutSpec: FLTextStringLayoutSpec(
                        model: FLTextStringLayoutModel(
                            string: string,
                            linkAttributes: model.text.decorator.linkAttributes,
                            openURL: ({ [weak self] url in
                                self?.delegate?.open(url: url)
                            })
                        )
                    )
                )

                items.append(item)
            case let .hidden(string: string, name: name):
                if model.expandedTextIndices.contains(index) {
                    let item = ListItem(
                        id: itemId + "_expanded",
                        layoutSpec: FLTextExpandedHiddenStringLayoutSpec(model: (string, name))
                    )

                    items.append(item)
                } else {
                    let item = ListItem(
                        id: itemId + "_collapsed",
                        layoutSpec: FLTextCollapsedHiddenStringLayoutSpec(model: name)
                    )

                    item.didTap = { [weak self] view, _ in
                        view.animated(action: {
                            self?.delegate?.showHiddenText(index: index)
                        })
                    }

                    items.append(item)
                }
            case let .quote(string):
                let item = ListItem(
                    id: itemId,
                    layoutSpec: FLTextQuoteLayoutSpec(model: string)
                )

                items.append(item)
            case let .image(url):
                if let image = model.images[index] {
                    let item = ListItem(
                        id: itemId + "_image",
                        layoutSpec: FLTextImageLayoutSpec(model: image)
                    )

                    items.append(item)
                } else {
                    let item = ListItem(
                        id: itemId + "_loading",
                        layoutSpec: FLTextImageLoadingLayoutSpec(model: (url, { [weak self] image in
                            self?.delegate?.save(image: image, at: index)
                        }))
                    )

                    items.append(item)
                }
            case let .photo(index):
                if let image = model.images[index] {
                    let item = ListItem(
                        id: itemId + "_image",
                        layoutSpec: FLTextImageLayoutSpec(model: image)
                    )

                    items.append(item)
                } else if let url = delegate?.makeURLFrom(photoIndex: index) {
                    let item = ListItem(
                        id: itemId + "_loading",
                        layoutSpec: FLTextImageLoadingLayoutSpec(model: (url, { [weak self] image in
                            self?.delegate?.save(image: image, at: index)
                        }))
                    )

                    items.append(item)
                }
            case .video:
                break
            }

            items.append(ListItem(
                id: itemId + "_sep",
                layoutSpec: EmptySpaceLayoutSpec(model: (UIColor.white, 24))
            ))
        }

        return items
    }
}
