import Foundation
import RxSwift
import FantLabModels
import FantLabUtils
import FantLabWebAPI
import FantLabModels

final class WorkInteractor {
    struct DataModel {
        let work: WorkModel
        let analogs: [WorkPreviewModel]
        let contentRoot: WorkTreeNode
    }

    private let state = ObservableValue<DataState<DataModel>>(.initial)
    private let reviewsState = ObservableValue<DataState<[WorkReviewModel]>>(.initial)

    private let disposeBag = DisposeBag()

    private let workId: Int

    init(workId: Int) {
        self.workId = workId
    }

    // MARK: -

    var stateObservable: Observable<DataState<DataModel>> {
        return state.observable()
    }

    var reviewsStateObservable: Observable<DataState<[WorkReviewModel]>> {
        return reviewsState.observable()
    }

    // MARK: -

    var workURL: URL? {
        return URL(string: "https://\(Hosts.portal)/work\(workId)")
    }

    func loadWork() {
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
                onError: { [weak self] _ in
                    self?.state.value = .error
                }
            )
            .disposed(by: disposeBag)
    }

    func loadReviews() {
        if reviewsState.value.isLoading || reviewsState.value.isIdle {
            return
        }

        reviewsState.value = .loading

        let request = NetworkClient.shared.perform(request: GetWorkReviewsNetworkRequest(workId: workId, page: 0, sort: .rating))

        request
            .subscribe(
                onNext: { [weak self] reviews in
                    self?.reviewsState.value = .idle(reviews)
                },
                onError: { [weak self] _ in
                    self?.reviewsState.value = .error
                }
            )
            .disposed(by: disposeBag)
    }
}
