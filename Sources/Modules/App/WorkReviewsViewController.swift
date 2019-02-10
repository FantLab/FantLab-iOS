import Foundation
import UIKit
import RxSwift
import ALLKit
import FantLabUtils
import FantLabStyle
import FantLabModels
import FantLabText
import FantLabBaseUI
import FantLabLayoutSpecs
import FantLabStyle
import FantLabContentBuilders
import FantLabWebAPI

final class WorkReviewsViewController: ListViewController {
    private struct DataModel {
        var reviews: [WorkReviewModel] = []
        var listIsFull: Bool = false
        var sort: ReviewsSort = .date
        var page: Int = 0
        var state: DataState<Void> = .initial
    }

    private let state = ObservableValue(DataModel(
        reviews: [],
        listIsFull: false,
        sort: .rating,
        page: 0,
        state: .initial
    ))

    private let reviewsCount: Int
    private let reviewHeaderMode: WorkReviewHeaderMode
    private let makeRequestObservable: (Int, ReviewsSort) -> Observable<[WorkReviewModel]>
    private let requestSubject = PublishSubject<ReviewsSort>()
    private let contentBuilder: WorkReviewsListContentBuilder

    init(workId: Int, reviewsCount: Int) {
        self.reviewsCount = reviewsCount

        makeRequestObservable = { (page, sort) in
            return NetworkClient.shared.perform(request: GetWorkReviewsNetworkRequest(
                workId: workId,
                page: page,
                sort: sort
            ))
        }

        reviewHeaderMode = .user
        contentBuilder = WorkReviewsListContentBuilder(headerMode: .user)

        super.init(nibName: nil, bundle: nil)
    }

    init(userId: Int, reviewsCount: Int) {
        self.reviewsCount = reviewsCount

        makeRequestObservable = { (page, sort) in
            return NetworkClient.shared.perform(request: GetUserReviewsNetworkRequest(
                userId: userId,
                page: page,
                sort: sort
            ))
        }

        reviewHeaderMode = .work
        contentBuilder = WorkReviewsListContentBuilder(headerMode: .work)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private let sortSelectionControl = UISegmentedControl(items: ["Оценка", "Дата", "Рейтинг"])

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Отзывы (\(reviewsCount))"

        contentBuilder.stateContentBuilder.errorContentBuilder.onRetry = { [weak self] in
            self?.loadNextPage()
        }

        contentBuilder.onLastItemDisplay = { [weak self] in
            self?.loadNextPage()
        }

        contentBuilder.singleReviewContentBuilder.onReviewUserTap = { userId in
            AppRouter.shared.openUserProfile(id: userId)
        }

        contentBuilder.singleReviewContentBuilder.onReviewWorkTap = { workId in
            AppRouter.shared.openWork(id: workId)
        }

        let headerMode = reviewHeaderMode

        contentBuilder.singleReviewContentBuilder.onReviewTextTap = { review in
            AppRouter.shared.openReview(model: review, headerMode: headerMode)
        }

        setupUI()
        setupRequest()
        setupStateMapping()

        loadNextPage()
    }

    // MARK: -

    private func setupUI() {
        view.backgroundColor = UIColor.white

        adapter.collectionView.contentInset.top = 48

        adapter.scrollEvents.didScroll = { [weak self] scrollView in
            self?.isSortSelectionControlHidden = (scrollView.contentOffset.y + scrollView.adjustedContentInset.top) > 10
        }

        sortSelectionControl.backgroundColor = UIColor.white
        sortSelectionControl.selectedSegmentIndex = 2
        Appearance.setup(segmentedControl: sortSelectionControl)
        view.addSubview(sortSelectionControl)
        sortSelectionControl.pinEdges(to: view.safeAreaLayoutGuide, top: 8, left: 16, bottom: .nan, right: 16)

        sortSelectionControl.all_setEventHandler(for: .valueChanged) { [weak self] in
            guard let strongSelf = self else { return }

            let selectedSegmentIndex = strongSelf.sortSelectionControl.selectedSegmentIndex

            let sort: ReviewsSort

            switch selectedSegmentIndex {
            case 0:
                sort = .mark
            case 2:
                sort = .rating
            default:
                sort = .date
            }

            strongSelf.sort(by: sort)
        }
    }

    private func setupStateMapping() {
        state.observable()
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .map { [weak self] data -> [ListItem] in
                return self?.contentBuilder.makeListItemsFrom(model: (data.reviews, data.state)) ?? []
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.adapter.set(items: items)
            })
            .disposed(by: disposeBag)
    }

    // MARK: -

    private func setupRequest() {
        requestSubject
            .flatMapLatest { [weak self] sort -> Observable<Void> in
                return self?.makeRequest(sort: sort) ?? .empty()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func makeRequest(sort: ReviewsSort) -> Observable<Void> {
        let pageToLoad: Int

        do {
            var value = state.value

            if sort != value.sort {
                value = DataModel(
                    reviews: [],
                    listIsFull: false,
                    sort: sort,
                    page: 0,
                    state: .loading
                )
            } else {
                value.state = .loading
            }

            state.value = value

            pageToLoad = value.page + 1
        }

        return makeRequestObservable(pageToLoad, sort)
            .do(
                onNext: ({ [weak self] reviews in
                    guard let strongSelf = self else { return }

                    var value = strongSelf.state.value
                    value.reviews.append(contentsOf: reviews)
                    value.listIsFull = reviews.isEmpty
                    value.page = pageToLoad
                    value.state = .idle(())
                    strongSelf.state.value = value
                }),
                onError: ({ [weak self] error in
                    guard let strongSelf = self else { return }

                    var value = strongSelf.state.value
                    value.state = .error(error)
                    strongSelf.state.value = value
                })
            )
            .map({ _ in })
            .catchErrorJustReturn(())
    }

    // MARK: -

    private func sort(by sort: ReviewsSort) {
        guard sort != state.value.sort else {
            return
        }

        requestSubject.onNext(sort)
    }

    private func loadNextPage() {
        let data = self.state.value

        guard !data.state.isLoading && !data.listIsFull else {
            return
        }

        requestSubject.onNext(data.sort)
    }

    // MARK: -

    private var isSortSelectionControlHidden: Bool = false {
        didSet {
            guard isSortSelectionControlHidden != oldValue else {
                return
            }

            let alpha: CGFloat = isSortSelectionControlHidden ? 0 : 1
            let transform: CGAffineTransform = isSortSelectionControlHidden ? CGAffineTransform(translationX: 0, y: -40) : .identity

            UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: { [sortSelectionControl] in
                sortSelectionControl.alpha = alpha
                sortSelectionControl.transform = transform
            })
        }
    }
}
