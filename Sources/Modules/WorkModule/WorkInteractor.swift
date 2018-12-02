import Foundation
import RxSwift
import FantLabModels
import FantLabUtils
import FantLabWebAPI

final class WorkInteractor {
    enum State {
        case idle(WorkModel, [WorkAnalogModel])
        case loading
        case hasError
    }

    private let state = ObservableValue(State.loading)

    private let disposeBag = DisposeBag()

    private let workId: Int

    init(workId: Int) {
        self.workId = workId
    }

    func loadWork() {
        let workObservable = NetworkClient.shared.perform(request: GetWorkNetworkRequest(workId: workId))
        let analogsObservable = NetworkClient.shared.perform(request: GetWorkAnalogsNetworkRequest(workId: workId))

        Observable.zip(workObservable, analogsObservable)
            .subscribe(
                onNext: { [weak self] (work, analogs) in
                    self?.state.value = .idle(work, analogs)
                },
                onError: { [weak self] _ in
                    self?.state.value = .hasError
                }
            )
            .disposed(by: disposeBag)
    }

    var stateObservable: Observable<State> {
        return state.observable()
    }
}
