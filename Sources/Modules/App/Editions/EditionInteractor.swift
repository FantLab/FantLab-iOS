import Foundation
import RxSwift
import FantLabModels
import FantLabUtils
import FantLabWebAPI
import FantLabModels

final class EditionInteractor {
    private let state = ObservableValue<DataState<EditionModel>>(.initial)

    private let disposeBag = DisposeBag()

    private let editionId: Int

    init(editionId: Int) {
        self.editionId = editionId
    }

    // MARK: -

    var stateObservable: Observable<DataState<EditionModel>> {
        return state.observable()
    }

    // MARK: -

    func loadEdition() {
        if state.value.isLoading || state.value.isIdle {
            return
        }

        state.value = .loading

        let editionRequest = NetworkClient.shared.perform(request: GetEditionNetworkRequest(editionId: editionId))

        editionRequest
            .subscribe(
                onNext: { [weak self] edition in
                    self?.state.value = .idle(edition)
                },
                onError: { [weak self] _ in
                    self?.state.value = .error
                }
            )
            .disposed(by: disposeBag)
    }
}
