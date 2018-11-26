import Foundation
import UIKit
import ALLKit
import RxSwift
import FantLabUtils
import FantLabStyle
import FantLabModels
import FantLabSharedUI

final class WorkViewController: ListViewController {
    private let disposeBag = DisposeBag()
    private let router: WorkModuleRouter
    private let interactor: WorkInteractor

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
        guard !model.authors.isEmpty else {
            return
        }

        if model.authors.count == 1 {
            let author = model.authors[0]

            router.openAuthor?(author.type, author.id)

            return
        }

        do {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            model.authors.forEach { author in
                let action = UIAlertAction(title: author.name, style: .default, handler: { [weak self] _ in
                    self?.router.openAuthor?(author.type, author.id)
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

        router.openWorkReviews?(model.id)
    }

    private func openDescriptionAndNotes(work model: WorkModel) {
        let author = model.descriptionAuthor

        let text = [
            model.descriptionText,
            author.isEmpty ? "" : "© " + author,
            model.notes
            ].compactAndJoin("\n")

        router.showInteractiveText?("Описание", text)
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
        case .idle(let workModel):
            return makeListItemsFrom(work: workModel)
        }
    }

    private func makeListItemsFrom(work model: WorkModel) -> [ListItem] {
        imageBackgroundViewController?.imageURL = model.imageURL // TODO: move

        let modelId = String(model.id)

        var items: [ListItem] = []

        items.append(contentsOf: makeSectionItems(
            id: modelId + "_header",
            hasSeparator: false,
            layoutSpec: WorkHeaderLayoutSpec(model: model),
            onSelect: { [weak self] in
                self?.openAuthors(work: model)
            }
        ))

        items.append(contentsOf: makeSectionItems(
            id: modelId + "_rating",
            hasSeparator: true,
            layoutSpec: RightArrowLayoutSpec(model: WorkRatingLayoutSpec(model: model)),
            onSelect: {  [weak self] in
                self?.openReviews(work: model)
            }
        ))

        items.append(contentsOf: makeSectionItems(
            id: modelId + "_description",
            hasSeparator: true,
            layoutSpec: RightArrowLayoutSpec(model: WorkDescriptionLayoutSpec(model: model)),
            onSelect: { [weak self] in
                self?.openDescriptionAndNotes(work: model)
            }
        ))

        return items
    }

    private func makeSectionItems(id: String,
                                  hasSeparator: Bool,
                                  layoutSpec: @autoclosure () -> LayoutSpec,
                                  onSelect: (() -> Void)?) -> [ListItem] {
        var items: [ListItem] = []

        if hasSeparator {
            let itemId = id + "_separator"

            let item = ListItem(
                id: itemId,
                model: itemId,
                layoutSpec: WorkSectionSeparatorLayoutSpec()
            )

            items.append(item)
        }

        do {
            let item = ListItem(
                id: id,
                model: id,
                layoutSpec: layoutSpec()
            )

            item.actions.onSelect = onSelect

            items.append(item)
        }

        return items
    }
}
