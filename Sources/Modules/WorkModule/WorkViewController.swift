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
    private let router: WorkModuleRouter

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

            router.openAuthor(id: author.id, entityName: author.type)

            return
        }

        do {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            model.authors.forEach { author in
                let action = UIAlertAction(title: author.name, style: .default, handler: { [weak self] _ in
                    self?.router.openAuthor(id: author.id, entityName: author.type)
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

        let vc = WorkReviewsViewController(workId: model.id, router: router)

        router.push(viewController: vc)
    }

    private func openDescriptionAndNotes(work model: WorkModel) {
        let author = model.descriptionAuthor

        let text = [
            model.descriptionText,
            author.isEmpty ? "" : "© " + author,
            model.notes
            ].compactAndJoin("\n")

        router.showInteractiveText(text, title: "Описание")
    }

    private func openContent(workModel: WorkModel) {
        let vc = WorkContentViewController(workModel: workModel, router: router)

        router.push(viewController: vc)
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

        // rating TODO:

//        if model.rating > 0 && model.votes > 0 {
//            let item = ListItem(
//                id: UUID().uuidString,
//                layoutSpec: WorkRatingLayoutSpec(model: model)
//            )
//
//            items.append(item)
//        }

        // description

        if !model.descriptionText.isEmpty || !model.notes.isEmpty {
            let item = ListItem(
                id: UUID().uuidString,
                layoutSpec: WorkDescriptionLayoutSpec(model: model)
            )

            item.actions.onSelect = { [weak self] in
                self?.openDescriptionAndNotes(work: model)
            }

            items.append(item)
        }

        // classification

        if !model.classificatory.isEmpty {
            items.append(ListItem(
                id: UUID().uuidString,
                layoutSpec: WorkGenresLayoutSpec(model: model)
            ))
        }

        // parents

        if !model.parents.isEmpty {
            items.append(ListItem(
                id: UUID().uuidString,
                layoutSpec: EmptySpaceLayoutSpec(model: (UIColor.white, 32))
            ))

            items.append(ListItem(
                id: UUID().uuidString,
                layoutSpec: WorkSectionTitleLayoutSpec(model: WorkSectionTitleLayoutModel(
                    title: "Входит в",
                    icon: UIImage(named: "layers"),
                    count: 0,
                    showArrow: false
                ))
            ))

            items.append(ListItem(
                id: UUID().uuidString,
                layoutSpec: EmptySpaceLayoutSpec(model: (UIColor.white, 8))
            ))

            model.parents.forEach { parents in
                parents.enumerated().forEach({ (index, parentModel) in
                    let item = ListItem(
                        id: UUID().uuidString,
                        layoutSpec: WorkParentModelLayoutSpec(model: WorkParentModelLayoutModel(
                            work: parentModel,
                            level: index,
                            showArrow: parentModel.id > 0
                        ))
                    )

                    if parentModel.id > 0 {
                        item.actions.onSelect = { [weak self] in
                            self?.router.openWork(id: parentModel.id)
                        }
                    }

                    items.append(item)

                    items.append(ListItem(
                        id: UUID().uuidString,
                        layoutSpec: ItemSeparatorLayoutSpec()
                    ))
                })
            }
        }

        // content

        if !model.children.isEmpty {
            items.append(ListItem(
                id: UUID().uuidString,
                layoutSpec: EmptySpaceLayoutSpec(model: (UIColor.white, 32))
            ))

            if model.children.count < 7 {
                items.append(ListItem(
                    id: UUID().uuidString,
                    layoutSpec: WorkSectionTitleLayoutSpec(model: WorkSectionTitleLayoutModel(
                        title: "Содержание",
                        icon: UIImage(named: "content"),
                        count: 0,
                        showArrow: false
                    ))
                ))

                items.append(ListItem(
                    id: UUID().uuidString,
                    layoutSpec: EmptySpaceLayoutSpec(model: (UIColor.white, 8))
                ))

                model.children.forEach { work in
                    let item = ListItem(
                        id: UUID().uuidString,
                        layoutSpec: WorkChildModelLayoutSpec(model: work)
                    )

                    if work.id > 0 {
                        item.actions.onSelect = { [weak self] in
                            self?.router.openWork(id: work.id)
                        }
                    }

                    items.append(item)

                    items.append(ListItem(
                        id: UUID().uuidString,
                        layoutSpec: ItemSeparatorLayoutSpec()
                    ))
                }
            } else {
                let item = ListItem(
                    id: UUID().uuidString,
                    layoutSpec: WorkSectionTitleLayoutSpec(model: WorkSectionTitleLayoutModel(
                        title: "Содержание",
                        icon: UIImage(named: "content"),
                        count: model.children.count,
                        showArrow: true
                    ))
                )

                item.actions.onSelect = { [weak self] in
                    self?.openContent(workModel: model)
                }

                items.append(item)

                items.append(ListItem(
                    id: UUID().uuidString,
                    layoutSpec: EmptySpaceLayoutSpec(model: (UIColor.white, 12))
                ))

                items.append(ListItem(
                    id: UUID().uuidString,
                    layoutSpec: ItemSeparatorLayoutSpec()
                ))
            }
        }

        // analogs

        if !analogModels.isEmpty {
            items.append(ListItem(
                id: UUID().uuidString,
                layoutSpec: EmptySpaceLayoutSpec(model: (UIColor.white, 48))
            ))

            items.append(ListItem(
                id: UUID().uuidString,
                layoutSpec: WorkSectionTitleLayoutSpec(model: WorkSectionTitleLayoutModel(
                    title: "Похожие",
                    icon: UIImage(named: "analogs"),
                    count: analogModels.count,
                    showArrow: false
                ))
            ))

            items.append(ListItem(
                id: UUID().uuidString,
                layoutSpec: WorkAnalogListLayoutSpec(model: (analogModels, { [weak self] workId in
                    self?.router.openWork(id: workId)
                }))
            ))
        }

        // reviews

        if model.reviewsCount > 0 {
            items.append(ListItem(
                id: UUID().uuidString,
                layoutSpec: EmptySpaceLayoutSpec(model: (UIColor.white, 32))
            ))

            let item = ListItem(
                id: UUID().uuidString,
                layoutSpec: WorkSectionTitleLayoutSpec(model: WorkSectionTitleLayoutModel(
                    title: "Отзывы",
                    icon: UIImage(named: "reviews"),
                    count: model.reviewsCount,
                    showArrow: true
                ))
            )

            item.actions.onSelect = { [weak self] in
                self?.openReviews(work: model)
            }

            items.append(item)

            items.append(ListItem(
                id: UUID().uuidString,
                layoutSpec: EmptySpaceLayoutSpec(model: (UIColor.white, 12))
            ))

            items.append(ListItem(
                id: UUID().uuidString,
                layoutSpec: ItemSeparatorLayoutSpec()
            ))
        }

        // extra footer space

        items.append(ListItem(
            id: UUID().uuidString,
            layoutSpec: EmptySpaceLayoutSpec(model: (UIColor.white, 64))
        ))

        return items
    }
}
