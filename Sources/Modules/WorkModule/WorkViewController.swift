import Foundation
import UIKit
import ALLKit
import RxSwift
import FantLabUtils
import FantLabStyle
import FantLabModels
import FantLabSharedUI

enum TabIndex: String {
    case info
    case reviews
    case analogs
}

final class WorkViewController: ImageBackedListViewController {
    private let interactor: WorkInteractor
    private let router: WorkModuleRouter
    private let contentBuilder = WorkContentBuilder()
    private let expandCollapseSubject = PublishSubject<Void>()
    private let tabIndexSubject = PublishSubject<TabIndex>()

    init(workId: Int, router: WorkModuleRouter) {
        self.router = router

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
                self?.router.openWork(id: workId)
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
                self?.router.openWork(id: workId)
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
                self?.router.openWork(id: workId)
            }

            contentBuilder.onAwardsTap = { [weak self] work in
                self?.openAwards(work: work)
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
    }

    // MARK: -

    private func openAwards(work model: WorkModel) {
        let vc = WorkAwardListViewController(awards: model.awards)

        navigationController?.pushViewController(vc, animated: true)
    }

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

        let vc = WorkReviewsViewController(
            workId: model.id,
            reviewsCount: model.reviewsCount,
            openReview: { [weak self] review in
                self?.openReview(review)
            }
        )

        router.push(viewController: vc)
    }

    private func openReview(_ model: WorkReviewModel) {
        let item = ListItem(
            id: "review",
            layoutSpec: WorkReviewHeaderLayoutSpec(model: model)
        )

        router.showInteractiveText(model.text, title: "Отзыв", headerListItems: [item])
    }

    private func openDescriptionAndNotes(work model: WorkModel) {
        let text = [model.descriptionText,
                    model.descriptionAuthor,
                    model.notes].compactAndJoin("\n\n")

        router.showInteractiveText(text, title: "Описание", headerListItems: [])
    }
}
