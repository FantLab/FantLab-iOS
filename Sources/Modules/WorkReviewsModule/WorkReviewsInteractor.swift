import Foundation
import RxSwift
import FantLabUtils
import FantLabModels
import FantLabWebAPI

final class WorkReviewsInteractor {
    struct State {
        enum Status {
            case idle
            case loading
            case error
        }

        var reviews: [WorkReviewModel] = []
        var listIsFull: Bool = false
        var sort: ReviewsSort = .date
        var page: Int = 0
        var status: Status = .idle
    }

    private let state = ObservableValue(State(
        reviews: [],
        listIsFull: false,
        sort: .date,
        page: 0,
        status: .idle
    ))

    private let disposeBag = DisposeBag()
    private let requestSubject = PublishSubject<ReviewsSort>()

    init(workId: Int) {
        requestSubject.flatMapLatest { [weak self] sort -> Observable<Void> in
            guard let strongSelf = self else {
                return .empty()
            }

            let pageToLoad: Int

            do {
                var state = strongSelf.state.value

                if sort != state.sort {
                    state = State(
                        reviews: [],
                        listIsFull: false,
                        sort: sort,
                        page: 0,
                        status: .loading
                    )
                } else {
                    state.status = .loading
                }

                strongSelf.state.value = state

                pageToLoad = state.page + 1
            }

            let request = GetWorkReviewsNetworkRequest(
                workId: workId,
                page: pageToLoad,
                sort: sort
            )

            return NetworkClient.shared.perform(request: request)
                .do(
                    onNext: ({ reviews in
                        guard let strongSelf = self else { return }

                        var state = strongSelf.state.value
                        state.reviews.append(contentsOf: reviews)
                        state.listIsFull = reviews.isEmpty
                        state.page = pageToLoad
                        state.status = .idle
                        strongSelf.state.value = state
                    }),
                    onError: ({ _ in
                        guard let strongSelf = self else { return }

                        var state = strongSelf.state.value
                        state.status = .error
                        strongSelf.state.value = state
                    })
                )
                .map({ _ in })
                .catchErrorJustReturn(())
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    deinit {
        requestSubject.onCompleted()
    }

    // MARK: -

    var stateObservable: Observable<State> {
        return state.observable()
    }

    func sort(by sort: ReviewsSort) {
        guard sort != state.value.sort else {
            return
        }

        requestSubject.onNext(sort)
    }

    func loadNextPage() {
        let state = self.state.value

        guard state.status != .loading && !state.listIsFull else {
            return
        }

        requestSubject.onNext(state.sort)
    }
}
