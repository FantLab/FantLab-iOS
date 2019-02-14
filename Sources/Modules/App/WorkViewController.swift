import Foundation
import UIKit
import ALLKit
import RxSwift
import FantLabUtils
import FantLabStyle
import FantLabModels
import FantLabBaseUI
import FantLabLayoutSpecs
import FantLabContentBuilders
import FantLabWebAPI

final class WorkViewController: ListViewController, WorkContentBuilderDelegate, WebURLProvider {
    private struct DataModel {
        let work: WorkModel
        let analogs: [WorkPreviewModel]
        let contentRoot: WorkTreeNode
    }

    private let workId: Int
    private let state = ObservableValue<DataState<DataModel>>(.initial)
    private let reviewsState = ObservableValue<DataState<[WorkReviewModel]>>(.initial)
    private let contentBuilder = DataStateContentBuilder(dataContentBuilder: WorkContentBuilder())
    private let expandCollapseSubject = PublishSubject<Void>()
    private let tabIndexSubject = PublishSubject<WorkContentTabIndex>()

    init(workId: Int) {
        self.workId = workId

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

        contentBuilder.dataContentBuilder.delegate = self

        contentBuilder.errorContentBuilder.onRetry = { [weak self] in
            self?.loadWork()
        }

        setupBackgroundImageWith(urlObservable: state.observable().map({ $0.data?.work.imageURL }))

        setupStateMapping()

        loadWork()
    }

    // MARK: -

    private func setupStateMapping() {
        Observable.combineLatest(state.observable(),
                                 reviewsState.observable(),
                                 tabIndexSubject.distinctUntilChanged(),
                                 expandCollapseSubject)
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ [weak self] args -> [ListItem] in
                let dataModel = args.0.map({ data -> WorkContentModel in
                    let reviewsDataModel = args.1.map({ reviews -> WorkReviewsShortListContentModel in
                        return (data.work, reviews, data.work.reviewsCount > reviews.count)
                    })

                    return (data.work, reviews: reviewsDataModel, analogs: data.analogs, workTree: data.contentRoot, tabIndex: args.2)
                })

                return self?.contentBuilder.makeListItemsFrom(model: dataModel) ?? []
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.adapter.set(items: items)
            })
            .disposed(by: disposeBag)

        expandCollapseSubject.onNext(())
        tabIndexSubject.onNext(.info)
    }

    // MARK: -

    private func loadWork() {
        if state.value.isLoading || state.value.isIdle {
            return
        }

        state.value = .loading

        let workRequest = NetworkClient.shared.perform(request: GetWorkNetworkRequest(workId: workId))
        let analogsRequest = NetworkClient.shared.perform(request: GetWorkAnalogsNetworkRequest(workId: workId))

        Observable.zip(workRequest, analogsRequest)
            .subscribe(
                onNext: { [weak self] (work, analogs) in
                    self?.state.value = .idle(DataModel(
                        work: work,
                        analogs: analogs,
                        contentRoot: work.children.makeWorkTree()
                    ))
                },
                onError: { [weak self] error in
                    self?.state.value = .error(error)
                }
            )
            .disposed(by: disposeBag)
    }

    private func loadReviews() {
        if reviewsState.value.isLoading || reviewsState.value.isIdle {
            return
        }

        reviewsState.value = .loading

        let request = NetworkClient.shared.perform(request: GetWorkReviewsNetworkRequest(workId: workId, page: 0, sort: .rating))

        request
            .subscribe(
                onNext: { [weak self] reviews in
                    self?.reviewsState.value = .idle(Array(reviews.prefix(5)))
                },
                onError: { [weak self] error in
                    self?.reviewsState.value = .error(error)
                }
            )
            .disposed(by: disposeBag)
    }

    // MARK: - WorkContentBuilderDelegate

    func onHeaderTap(work: WorkModel) {
        AppRouter.shared.openWorkAuthors(work: work)
    }

    func onTabTap(tab: WorkContentTabIndex) {
        if tab == .reviews {
            loadReviews()
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
        loadReviews()
    }

    func onShowAllReviewsTap(work: WorkModel) {
        guard work.reviewsCount > 0 else {
            return
        }

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
}
