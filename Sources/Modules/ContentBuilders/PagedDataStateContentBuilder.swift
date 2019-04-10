import Foundation
import UIKit
import ALLKit
import FLStyle
import FLKit
import FLLayoutSpecs

public final class PagedDataStateContentBuilder<ModelType: IntegerIdProvider, BuilderType: ListContentBuilder>: ListContentBuilder where BuilderType.ModelType == [ModelType] {
    public typealias ModelType = PagedDataState<ModelType>

    public let itemsContentBuilder: BuilderType
    public let stateContentBuilder = DataStateContentBuilder(dataContentBuilder: EmptyContentBuilder())

    public init(itemsContentBuilder: BuilderType) {
        self.itemsContentBuilder = itemsContentBuilder
    }

    public var onLastItemDisplay: (() -> Void)?

    // MARK: -

    private var listItemsCache: [Int: [ListItem]] = [:]

    private var stateId: String = "" {
        didSet {
            if stateId != oldValue {
                listItemsCache = [:]
            }
        }
    }

    // MARK: -

    public func makeListItemsFrom(model: PagedDataState<ModelType>) -> [ListItem] {
        stateId = model.id

        var listItems: [ListItem] = []

        model.items.enumerated().forEach { (index, chunk) in
            if let cachedListItems = listItemsCache[index] {
                listItems.append(contentsOf: cachedListItems)
            } else {
                let newListItems = itemsContentBuilder.makeListItemsFrom(model: chunk)

                listItemsCache[index] = newListItems

                listItems.append(contentsOf: newListItems)
            }
        }

        if !model.isFull && !listItems.isEmpty {
            let triggerItem = ListItem(
                id: UUID().uuidString,
                layoutSpec: EmptySpaceLayoutSpec(model: (UIColor.white, 1))
            )

            triggerItem.willShow = { [weak self] _, _ in
                self?.onLastItemDisplay?()
            }

            listItems.append(triggerItem)
        }

        listItems.append(contentsOf: stateContentBuilder.makeListItemsFrom(model: model.state))

        return listItems
    }
}
