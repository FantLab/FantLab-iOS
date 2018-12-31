import Foundation
import RxSwift
import FantLabModels
import FantLabUtils
import FantLabWebAPI

enum DataState<T> {
    case initial
    case loading
    case error
    case idle(T)

    var isInitial: Bool {
        if case .initial = self { return true }
        return false
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var isError: Bool {
        if case .error = self { return true }
        return false
    }

    var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }
}

final class WorkInteractor {
    struct DataModel {
        let work: WorkModel
        let analogs: [WorkAnalogModel]
        let contentRoot: WorkContentTreeNode
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

    func loadWork() {
        if reviewsState.value.isLoading || reviewsState.value.isIdle {
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
                        contentRoot: WorkInteractor.makeContentTreeFrom(work: work)
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

    // MARK: -

    private static func makeContentTreeFrom(work workModel: WorkModel) -> WorkContentTreeNode {
        let rootNode = WorkContentTreeNode(id: 0, level: 0, model: nil)

        var head: WorkContentTreeNode = rootNode

        workModel.children.enumerated().forEach { (index, model) in
            let node = WorkContentTreeNode(id: index + 1, level: model.deepLevel, model: model)
            node.isExpanded = false

            if node.level == head.level {
                head.parent?.add(child: node)
            } else {
                while node.level <= head.level {
                    head = head.parent ?? rootNode
                }

                head.add(child: node)
            }

            head = node
        }

        rootNode.isExpanded = true

        return rootNode
    }
}
