import Foundation
import UIKit
import ALLKit
import FantLabUtils
import FantLabModels
import FantLabLayoutSpecs
import FantLabStyle

public final class NewsContentBuilder: ListContentBuilder {
    public typealias ModelType = [NewsModel]

    // MARK: -

    public init() {}

    // MARK: -

    public var onURLTap: ((URL) -> Void)?

    // MARK: -

    public func makeListItemsFrom(model: [NewsModel]) -> [ListItem] {
        var items: [ListItem] = []

        model.forEach { news in
            let itemId = news.url.absoluteString

            let newsItem = ListItem(
                id: itemId,
                layoutSpec: NewsLayoutSpec(model: news)
            )

            newsItem.didSelect = { [weak self] (cell, _) in
                CellSelection.scale(cell: cell, action: {
                    self?.onURLTap?(news.url)
                })
            }

            items.append(newsItem)

            items.append(ListItem(
                id: itemId + "_sep",
                layoutSpec: EmptySpaceLayoutSpec(model: (Colors.perfectGray, 8))
            ))
        }

        return items
    }
}
