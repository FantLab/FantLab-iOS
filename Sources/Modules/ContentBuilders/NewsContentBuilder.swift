import Foundation
import UIKit
import ALLKit
import FLKit
import FLModels
import FLLayoutSpecs
import FLStyle
import FLText

public struct NewsListViewState {
    public var news: [NewsModel]
    public var state: DataState<Void>

    public init(news: [NewsModel],
                state: DataState<Void>) {

        self.news = news
        self.state = state
    }
}

public final class NewsContentBuilder: ListContentBuilder {
    public typealias ModelType = NewsListViewState

    // MARK: -

    public init() {}

    public let stateContentBuilder = DataStateContentBuilder(dataContentBuilder: EmptyContentBuilder())

    public var onNewsTap: ((NewsModel) -> Void)?
    public var onLastItemDisplay: (() -> Void)?

    // MARK: -

    public func makeListItemsFrom(model: NewsListViewState) -> [ListItem] {
        var items: [ListItem] = []

        model.news.forEach { news in
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

        items.last?.willShow = { [weak self] _, _ in
            self?.onLastItemDisplay?()
        }

        items.append(contentsOf: stateContentBuilder.makeListItemsFrom(model: model.state))

        return items
    }
}
