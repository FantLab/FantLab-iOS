import Foundation
import UIKit
import ALLKit
import RxSwift
import FantLabUtils
import FantLabStyle
import FantLabModels
import FantLabSharedUI

final class WorkViewController: ListViewController {
    private enum Separator {
        case section
        case item
    }

    private let disposeBag = DisposeBag()
    private let interactor: WorkInteractor
    private weak var router: WorkModuleRouter?

    init(workId: Int, router: WorkModuleRouter) {
        self.router = router

        interactor = WorkInteractor(workId: workId)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MAKR: -

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)

        do {
            adapter.scrollEvents.didScroll = { [weak self] scrollView in
                let offset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top

                let position = min(100, max(0, -offset)) / 100

                self?.imageBackgroundViewController?.position = position
            }
        }

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

        interactor.loadWork()
    }

    // MARK: -

    private func openAuthors(work model: WorkModel) {
        let openAuthors = model.authors.filter({ $0.isOpened })

        guard !openAuthors.isEmpty else {
            return
        }

        if openAuthors.count == 1 {
            let author = model.authors[0]

            router?.openAuthor(id: author.id, entityName: author.type)

            return
        }

        do {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            model.authors.forEach { author in
                let action = UIAlertAction(title: author.name, style: .default, handler: { [weak self] _ in
                    self?.router?.openAuthor(id: author.id, entityName: author.type)
                })

                alert.addAction(action)
            }

            alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))

            present(alert, animated: true, completion: nil)
        }
    }

    private func openReviews(work model: WorkModel) {
        guard model.reviewsCount > 0 else {
            return
        }

        router?.openWorkReviews(workId: model.id)
    }

    private func openDescriptionAndNotes(work model: WorkModel) {
        let author = model.descriptionAuthor

        let text = [
            model.descriptionText,
            author.isEmpty ? "" : "© " + author,
            model.notes
            ].compactAndJoin("\n")

        router?.showInteractiveText(text, title: "Описание")
    }

    private func openContent(work model: WorkModel) {
        router?.openWorkContent(workModel: model)
    }

    private func openWorkAnalogs(_ models: [WorkAnalogModel]) {
        router?.showWorkAnalogs(models)
    }

    // MARK: -

    private let loadingItemId = UUID().uuidString

    private func makeListItemsFrom(state: WorkInteractor.State) -> [ListItem] {
        switch state {
        case .loading:
            let item = ListItem(id: loadingItemId, model: loadingItemId, layoutSpec: SpinnerLayoutSpec())

            return [item]
        case .hasError:
            return [] // TODO:
        case let .idle(workModel, analogModels):
            return makeListItemsFrom(work: workModel, analogs: analogModels)
        }
    }

    private func makeListItemsFrom(work model: WorkModel, analogs analogModels: [WorkAnalogModel]) -> [ListItem] {
        imageBackgroundViewController?.imageURL = model.imageURL // TODO: move

        var items: [ListItem] = []

        // header

        do {
            let item = ListItem(
                id: UUID().uuidString,
                layoutSpec: WorkHeaderLayoutSpec(model: model)
            )

            item.actions.onSelect = { [weak self] in
                self?.openAuthors(work: model)
            }

            items.append(item)
        }

        // content

        if !model.children.isEmpty {
            items.append(ListItem(
                id: UUID().uuidString,
                layoutSpec: SectionSeparatorLayoutSpec(model: 12)
            ))

            let item = ListItem(
                id: UUID().uuidString,
                layoutSpec: WorkSectionReferenceLayoutSpec(model: WorkSectionReferenceLayoutModel(
                    title: "Содержание",
                    count: model.children.count
                ))
            )

            item.actions.onSelect = { [weak self] in
                self?.openContent(work: model)
            }

            items.append(item)
        }

        // description and classification

        let hasDescription = !model.descriptionText.isEmpty || !model.notes.isEmpty
        let hasClassification = !model.classificatory.isEmpty

        if hasDescription || hasClassification {
            items.append(ListItem(
                id: UUID().uuidString,
                layoutSpec: SectionSeparatorLayoutSpec(model: 12)
            ))

            if hasDescription {
                let item = ListItem(
                    id: UUID().uuidString,
                    layoutSpec: WorkDescriptionLayoutSpec(model: model)
                )

                item.actions.onSelect = { [weak self] in
                    self?.openDescriptionAndNotes(work: model)
                }

                items.append(item)
            }

            if hasClassification {
                if hasDescription {
                    items.append(ListItem(
                        id: UUID().uuidString,
                        layoutSpec: ItemSeparatorLayoutSpec()
                    ))
                }

                items.append(ListItem(
                    id: UUID().uuidString,
                    layoutSpec: WorkGenresLayoutSpec(model: model)
                ))
            }
        }

        // analogs

        if !analogModels.isEmpty {
            items.append(ListItem(
                id: UUID().uuidString,
                layoutSpec: SectionSeparatorLayoutSpec(model: 12)
            ))

            let item = ListItem(
                id: UUID().uuidString,
                layoutSpec: WorkSectionReferenceLayoutSpec(model: WorkSectionReferenceLayoutModel(
                    title: "Похожие",
                    count: analogModels.count
                ))
            )

            item.actions.onSelect = { [weak self] in
                self?.openWorkAnalogs(analogModels)
            }

            items.append(item)
        }

        // reviews

        if model.reviewsCount > 0 {
            items.append(ListItem(
                id: UUID().uuidString,
                layoutSpec: SectionSeparatorLayoutSpec(model: 12)
            ))

            let item = ListItem(
                id: UUID().uuidString,
                layoutSpec: WorkSectionReferenceLayoutSpec(model: WorkSectionReferenceLayoutModel(
                    title: "Отзывы",
                    count: model.reviewsCount
                ))
            )

            item.actions.onSelect = { [weak self] in
                self?.openReviews(work: model)
            }

            items.append(item)
        }

        // footer separator

        do {
            items.append(ListItem(
                id: UUID().uuidString,
                layoutSpec: ItemSeparatorLayoutSpec()
            ))
        }

        return items
    }
}
