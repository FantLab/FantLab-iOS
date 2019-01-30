import Foundation
import UIKit
import ALLKit
import RxSwift
import FantLabUtils
import FantLabStyle
import FantLabModels
import FantLabBaseUI
import FantLabLayoutSpecs
import FantLabText

final class EditionViewController: ImageBackedListViewController {
    private let interactor: EditionInteractor

    init(editionId: Int) {
        interactor = EditionInteractor(editionId: editionId)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Издание"

        // image background

        do {
            setupWith(urlObservable: interactor.stateObservable.map({ state -> URL? in
                if case let .idle(data) = state {
                    return data.image
                }

                return nil
            }))

            adapter.scrollEvents.didScroll = { [weak self] scrollView in
                self?.updateImageVisibilityWith(scrollView: scrollView)
            }
        }

        // state

        do {
            interactor.stateObservable
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .map({ [weak self] state -> [ListItem] in
                    return self?.makeListItemsFrom(state: state) ?? []
                })
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] items in
                    self?.adapter.set(items: items)
                })
                .disposed(by: disposeBag)

            interactor.loadEdition()
        }
    }

    // MARK: -

    private func open(url: URL) {
        AppRouter.shared.openURL(url)
    }

    // MARK: -

    private func makeListItemsFrom(state: DataState<EditionModel>) -> [ListItem] {
        switch state {
        case .initial:
            return []
        case .loading:
            return [ListItem(id: "edition_loading", layoutSpec: SpinnerLayoutSpec())]
        case .error:
            return [] // TODO:
        case let .idle(model):
            return makeListItemsFrom(model: model)
        }
    }

    private func makeListItemsFrom(model: EditionModel) -> [ListItem] {
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
                decorator: TextListViewController.textDecorator,
                setupLinkAttribute: true
            )

            listItems.append(ListItem(
                id: "text_sep",
                layoutSpec: EmptySpaceLayoutSpec(model: (Colors.perfectGray, 8))
            ))

            listItems.append(ListItem(
                id: "text_spacing",
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
                        self?.open(url: url)
                    })
                )

                let itemId = "edition_text_\(index)"

                let contentItem = ListItem(
                    id: itemId,
                    layoutSpec: FLTextStringLayoutSpec(model: model)
                )

                let sepItem = ListItem(
                    id: itemId + "_separator",
                    layoutSpec: EmptySpaceLayoutSpec(model: (UIColor.white, 16))
                )

                return [contentItem, sepItem]
            }

            listItems.append(contentsOf: items)
        }

        return listItems
    }
}
