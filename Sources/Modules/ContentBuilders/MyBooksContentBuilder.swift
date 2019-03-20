import Foundation
import UIKit
import ALLKit
import FLKit
import FLModels
import FLLayoutSpecs
import FLStyle

public struct MyBooksViewState {
    public let works: [WorkPreviewModel]
    public let state: DataState<Void>

    public init(works: [WorkPreviewModel],
                state: DataState<Void>) {

        self.works = works
        self.state = state
    }
}

public final class MyBooksContentBuilder: ListContentBuilder {
    public typealias ModelType = MyBooksViewState

    public init() {}

    public let stateContentBuilder = DataStateContentBuilder(dataContentBuilder: EmptyContentBuilder())

    public var onWorkTap: ((Int) -> Void)?
    public var onWorkDeleteTap: ((Int) -> Void)?
    public var onFirstSwipeDisplay: ((SwipeViewPublicInterface) -> Void)?
    public var onLastItemDisplay: (() -> Void)?

    public func makeListItemsFrom(model: MyBooksViewState) -> [ListItem] {
        if model.works.isEmpty {
            let item = ListItem(
                id: "no_my_books",
                layoutSpec: NoMyBooksLayoutSpec()
            )

            return [item]
        }

        var items: [ListItem] = model.works.enumerated().flatMap { (index, work) -> [ListItem] in
            let itemId = "work_preview_\(work.id)"

            let workItem = ListItem(
                id: itemId,
                layoutSpec: WorkPreviewLayoutSpec(model: work)
            )

            do {
                let removeAction = SwipeAction(
                    layoutSpec: RemoveActionLayoutSpec(),
                    color: UIColor(rgb: 0xEA2027),
                    perform: ({ [weak self] in
                        self?.onWorkDeleteTap?(work.id)
                    })
                )

                workItem.swipeActions = SwipeActions([removeAction])
            }

            workItem.didTap = { [weak self] view, _ in
                view.animated(action: {
                    self?.onWorkTap?(work.id)
                })
            }

            if index == 0 {
                workItem.willShow = { [weak self] view, _ in
                    (view as? SwipeViewPublicInterface).flatMap({
                        self?.onFirstSwipeDisplay?($0)
                    })
                }
            }

            let sepItem = ListItem(
                id: itemId + "_sep",
                layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
            )

            return [workItem, sepItem]
        }

        items.last?.willShow = { [weak self] _, _ in
            self?.onLastItemDisplay?()
        }

        items.append(contentsOf: stateContentBuilder.makeListItemsFrom(model: model.state))

        items.forEach {
            $0.sizeConstraintsModifier = { sc in
                return SizeConstraints(width: sc.width!, height: .nan)
            }
        }

        return items
    }
}
