import Foundation
import RxSwift
import FantLabModels
import FantLabUtils
import FantLabWebAPI

final class WorkInteractor {
    enum State {
        case idle(WorkModel)
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
        let request = GetWorkNetworkRequest(workId: workId)

        NetworkClient.shared.perform(request: request)
            .subscribe(
                onNext: { [weak self] model in
                    self?.state.value = .idle(model)
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
