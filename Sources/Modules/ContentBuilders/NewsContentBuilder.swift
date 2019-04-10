import Foundation
import UIKit
import ALLKit
import FLKit
import FLModels
import FLLayoutSpecs
import FLStyle
import FLText

public final class NewsContentBuilder: ListContentBuilder {
    public typealias ModelType = [NewsModel]

    // MARK: -

    public init() {}

    public var onNewsTap: ((NewsModel) -> Void)?

    // MARK: -

    public func makeListItemsFrom(model: [NewsModel]) -> [ListItem] {
        var items: [ListItem] = []

        model.forEach { news in
            let itemId = "news_" + String(news.id)

            let newsText = FLStringPreview(string: news.text)

            guard !newsText.value.isEmpty else {
                return
            }

            let headerItem = ListItem(
                id: itemId + "_header",
                layoutSpec: NewsHeaderLayoutSpec(model: news)
            )

            headerItem.didTap = { [weak self] (view, _) in
                view.animated(action: {
                    self?.onNewsTap?(news)
                })
            }

            items.append(headerItem)

            let textItem = ListItem(
                id: itemId + "_text",
                layoutSpec: FLTextPreviewLayoutSpec(model: newsText)
            )

            textItem.didTap = { [weak self] (view, _) in
                view.animated(action: {
                    self?.onNewsTap?(news)
                })
            }

            items.append(textItem)

            items.append(ListItem(
                id: itemId + "_sep",
                layoutSpec: EmptySpaceLayoutSpec(model: (Colors.perfectGray, 8))
            ))
        }

        return items
    }
}
