import Foundation
import UIKit
import ALLKit
import RxSwift
import FantLabUtils
import FantLabStyle
import FantLabModels
import FantLabBaseUI
import FantLabLayoutSpecs

enum TabIndex: String {
    case info
    case reviews
    case analogs
}

final class WorkViewController: ImageBackedListViewController {
    private let interactor: WorkInteractor
    private let contentBuilder = WorkContentBuilder()
    private let expandCollapseSubject = PublishSubject<Void>()
    private let tabIndexSubject = PublishSubject<TabIndex>()

    init(workId: Int) {
        interactor = WorkInteractor(workId: workId)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    deinit {
        expandCollapseSubject.onCompleted()
        tabIndexSubject.onCompleted()
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""

        // content builder callbacks

        do {
            contentBuilder.onExpandOrCollapse = { [weak self] in
                self?.expandCollapseSubject.onNext(())
            }

            contentBuilder.onChildWorkTap = { [weak self] workId in
                self?.openWork(id: workId)
            }

            contentBuilder.onHeaderTap = { [weak self] work in
                self?.openAuthors(work: work)
            }

            contentBuilder.onTabTap = { [weak self] index in
                if index == .reviews {
                    self?.interactor.loadReviews()
                }

                self?.tabIndexSubject.onNext(index)
            }

            contentBuilder.onParentWorkTap = { [weak self] workId in
                self?.openWork(id: workId)
            }

            contentBuilder.onDescriptionTap = { [weak self] work in
                self?.openDescriptionAndNotes(work: work)
            }

            contentBuilder.onReviewTap = { [weak self] review in
                self?.openReview(review)
            }

            contentBuilder.onShowAllReviewsTap = { [weak self] work in
                self?.openReviews(work: work)
            }

            contentBuilder.onWorkAnalogTap = { [weak self] workId in
                self?.openWork(id: workId)
            }

            contentBuilder.onAwardsTap = { [weak self] work in
                self?.openAwards(work: work)
            }

            contentBuilder.onEditionsTap = { [weak self] work in
                self?.openEditions(work: work)
            }

            contentBuilder.onEditionTap = { [weak self] editionId in
                self?.openEdition(id: editionId)
            }
        }

        // image background

        do {
            setupWith(urlObservable: interactor.stateObservable.map({ state -> URL? in
                if case let .idle(data) = state {
                    return data.work.imageURL
                }

                return nil
            }))

            adapter.scrollEvents.didScroll = { [weak self] scrollView in
                self?.updateImageVisibilityWith(scrollView: scrollView)
            }
        }

        // state

        do {
            Observable.combineLatest(interactor.stateObservable,
                                     interactor.reviewsStateObservable,
                                     tabIndexSubject.distinctUntilChanged(),
                                     expandCollapseSubject)
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .map({ [weak self] args -> [ListItem] in
                    return self?.contentBuilder.makeListItemsFrom(
                        state: args.0,
                        reviewsState: args.1,
                        tabIndex: args.2
                        ) ?? []
                })
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] items in
                    self?.adapter.set(items: items)
                })
                .disposed(by: disposeBag)

            expandCollapseSubject.onNext(())
            tabIndexSubject.onNext(.info)

            interactor.loadWork()
        }

        // share

        do {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        }
    }

    // MARK: -

    private func openEditions(work model: WorkModel) {
        AppRouter.shared.openEditionList(model.editionBlocks)
    }

    private func openWork(id: Int) {
        AppRouter.shared.openWork(id: id)
    }

    private func openAwards(work model: WorkModel) {
        AppRouter.shared.openAwards(model.awards)
    }

    private func openAuthors(work model: WorkModel) {
        let openAuthors = model.authors.filter({ $0.isOpened })

        guard !openAuthors.isEmpty else {
            return
        }

        if openAuthors.count == 1 {
            let author = model.authors[0]

            openAuthor(id: author.id, entityType: author.type)

            return
        }

        do {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            model.authors.forEach { author in
                let action = UIAlertAction(title: author.name, style: .default, handler: { [weak self] _ in
                    self?.openAuthor(id: author.id, entityType: author.type)
                })

                alert.addAction(action)
            }

            alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))

            present(alert, animated: true, completion: nil)
        }
    }

    private func openAuthor(id: Int, entityType: String) {
        AppRouter.shared.openAuthor(id: id)
    }

    private func openReviews(work model: WorkModel) {
        guard model.reviewsCount > 0 else {
            return
        }

        AppRouter.shared.openWorkReviews(workId: model.id, reviewsCount: model.reviewsCount)
    }

    private func openReview(_ model: WorkReviewModel) {
        AppRouter.shared.openReview(model: model)
    }

    private func openDescriptionAndNotes(work model: WorkModel) {
        let string = [model.descriptionText,
                      model.descriptionAuthor,
                      model.notes].compactAndJoin("\n\n")

        AppRouter.shared.openText(title: "Описание", string: string, customHeaderListItems: [], makePhotoURL: nil)
    }

    private func openEdition(id: Int) {
        AppRouter.shared.openEdition(id: id)
    }

    @objc
    private func share() {
        guard let url = interactor.workURL else {
            return
        }

        AppRouter.shared.share(url: url)
    }
}
