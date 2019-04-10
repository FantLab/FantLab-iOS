import Foundation
import UIKit
import ALLKit
import RxSwift
import FLKit
import FLStyle
import FLModels
import FLUIKit
import FLLayoutSpecs
import FLContentBuilders
import FLWebAPI

extension WorkContentTabIndex: CustomStringConvertible {
    public var description: String {
        switch self {
        case .info:
            return "Обзор"
        case .reviews:
            return "Отзывы"
        case .analogs:
            return "Похожие"
        }
    }
}

final class WorkViewController: ListViewController<DataStateContentBuilder<WorkContentBuilder>>, WorkContentBuilderDelegate, WebURLProvider, NavBarItemsProvider {
    private struct DataModel {
        let work: WorkModel
        let analogs: [WorkPreviewModel]
        let contentRoot: WorkTreeNode
    }

    private let workId: Int
    private let workDataSource: DataSource<DataModel>
    private let reviewsDataSource: DataSource<[WorkReviewModel]>
    private let expandCollapseSubject = PublishSubject<Void>()
    private let tabIndexSubject = PublishSubject<WorkContentTabIndex>()
    private let myBookBtn = UIButton(type: .system)
    private var myBookItem: NavBarItem?

    deinit {
        expandCollapseSubject.onCompleted()
        tabIndexSubject.onCompleted()
    }

    init(workId: Int) {
        self.workId = workId

        do {
            let workRequest = AppServices.network.perform(request: GetWorkNetworkRequest(workId: workId))
            let analogsRequest = AppServices.network.perform(request: GetWorkAnalogsNetworkRequest(workId: workId))

            let loadObservable = Observable.zip(workRequest, analogsRequest).map { (work, analogs) -> DataModel in
                DataModel(
                    work: work,
                    analogs: analogs,
                    contentRoot: work.children.makeWorkTree()
                )
            }

            workDataSource = DataSource(loadObservable: loadObservable)
        }

        do {
            let loadObservable = AppServices.network.perform(request: GetWorkReviewsNetworkRequest(workId: workId, page: 0, sort: .rating)).map { reviews -> [WorkReviewModel] in
                Array(reviews.prefix(5))
            }

            reviewsDataSource = DataSource(loadObservable: loadObservable)
        }

        super.init(contentBuilder: DataStateContentBuilder(dataContentBuilder: WorkContentBuilder()))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        contentBuilder.dataContentBuilder.delegate = self

        contentBuilder.errorContentBuilder.onRetry = { [weak self] in
            self?.workDataSource.load()
        }

        setupUI()
        bindUI()

        workDataSource.load()
    }

    // MARK: -

    private func setupUI() {
        myBookBtn.pin(.width).const(40).equal()
        myBookBtn.pin(.height).const(40).equal()
        myBookBtn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        myBookBtn.all_setEventHandler(for: .touchUpInside) { [weak self] in
            self?.toggleMyBookState()
        }

        let btn = myBookBtn

        myBookItem = NavBarItem(margin: 8) { btn }
    }

    private func bindUI() {
        tabIndexSubject
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { tab in
                AppAnalytics.logWorkTabOpen(name: tab.description)
            })
            .disposed(by: disposeBag)

        let workId = self.workId

        AppServices.myBooks.eventStream
            .filter { event -> Bool in
                switch event {
                case let .add(workId: id, group: _):
                    return id == workId
                case let .remove(workId: id):
                    return id == workId
                }
            }
            .map { event -> Bool in
                switch event {
                case .add:
                    return true
                case .remove:
                    return false
                }
            }
            .startWith(AppServices.myBooks.contains(workId: workId))
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isMyBook in
                self?.isMyBook = isMyBook
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(workDataSource.stateObservable,
                                 reviewsDataSource.stateObservable,
                                 tabIndexSubject.distinctUntilChanged(),
                                 expandCollapseSubject)
            .map({ arg -> DataState<WorkViewState> in
                return arg.0.map({ data -> WorkViewState in
                    return WorkViewState(
                        work: data.work,
                        workTree: data.contentRoot,
                        analogs: data.analogs,
                        reviews: arg.1,
                        tabIndex: arg.2
                    )
                })
            })
            .subscribe(onNext: { [weak self] viewState in
                self?.apply(viewState: viewState)
            })
            .disposed(by: disposeBag)

        expandCollapseSubject.onNext(())
        tabIndexSubject.onNext(.info)
    }

    // MARK: -

    private func toggleMyBookState() {
        let id = workId

        let alert = Alert()

        if isMyBook {
            alert.add(negativeAction: "Удалить") {
                AppServices.myBooks.remove(workId: id)
            }
        } else {
            MyBookModel.Group.allCases.forEach { group in
                alert.add(positiveAction: group.description, perform: {
                    AppServices.myBooks.add(workId: id, group: group)
                })
            }
        }

        alert.set(cancelAction: "Отмена") {}

        let vc = UIAlertController(alert: alert, preferredStyle: .actionSheet)

        present(vc, animated: true, completion: nil)
    }

    private var isMyBook: Bool = false {
        didSet {
            let isOn = isMyBook

            UIView.transition(
                with: myBookBtn,
                duration: 0.2,
                options: [.beginFromCurrentState, .transitionCrossDissolve],
                animations: ({ [weak self] in
                    self?.myBookBtn.setImage(UIImage(named: isOn ? "heart_on" : "heart_off"), for: [])
                })
            )
        }
    }

    // MARK: - WorkContentBuilderDelegate

    func onHeaderTap(work: WorkModel) {
        AppAnalytics.logWorkAuthorsTap()
        
        AppRouter.shared.openWorkAuthors(work: work)
    }

    func onTabTap(tab: WorkContentTabIndex) {
        if tab == .reviews {
            reviewsDataSource.load()
        }

        tabIndexSubject.onNext(tab)
    }

    func onDescriptionTap(work: WorkModel) {
        let string = [work.descriptionText,
                      work.descriptionAuthor,
                      work.notes].compactAndJoin("\n\n")

        AppRouter.shared.openText(title: "Описание", string: string, customHeaderListItems: [], makePhotoURL: nil)
    }

    func onExpandOrCollapse() {
        expandCollapseSubject.onNext(())
    }

    func onWorkTap(id: Int) {
        AppRouter.shared.openWork(id: id)
    }

    func onReviewUserTap(userId: Int) {
        AppRouter.shared.openUserProfile(id: userId)
    }

    func onReviewTextTap(review: WorkReviewModel) {
        AppRouter.shared.openReview(model: review, headerMode: .user)
    }

    func onReviewsErrorTap() {
        reviewsDataSource.load()
    }

    func onShowAllReviewsTap(work: WorkModel) {
        guard work.reviewsCount > 0 else {
            return
        }

        AppAnalytics.logShowAllReviewsButtonTap()

        AppRouter.shared.openWorkReviews(workId: work.id, reviewsCount: work.reviewsCount)
    }

    func onAwardsTap(work: WorkModel) {
        AppRouter.shared.openAwards(work.awards)
    }

    func onEditionsTap(work: WorkModel) {
        AppRouter.shared.openEditionList(work.editionBlocks)
    }

    func onEditionTap(id: Int) {
        AppRouter.shared.openEdition(id: id)
    }

    // MARK: - WebURLProvider

    var webURL: URL? {
        return URL(string: "https://\(Hosts.portal)/work\(workId)")
    }

    // MARK: - NavBarItemsProvider

    var leftItems: [NavBarItem] {
        return []
    }

    var rightItems: [NavBarItem] {
        return [myBookItem].compactMap({ $0 })
    }
}
