import Foundation
import RxSwift
import FantLabModels
import FantLabUtils
import FantLabWebAPI
import FantLabModels

final class AuthorInteractor {
    struct DataModel {
        let author: AuthorModel
        let contentRoot: WorkTreeNode
    }

    private let state = ObservableValue<DataState<DataModel>>(.initial)

    private let disposeBag = DisposeBag()

    private let authorId: Int

    init(authorId: Int) {
        self.authorId = authorId
    }

    // MARK: -

    var stateObservable: Observable<DataState<DataModel>> {
        return state.observable()
    }

    // MARK: -

    var authorURL: URL? {
        return URL(string: "https://\(Hosts.portal)/autor\(authorId)")
    }

    func loadAuthor() {
        if state.value.isLoading || state.value.isIdle {
            return
        }

        state.value = .loading

        let authorRequest = NetworkClient.shared.perform(request: GetAuthorNetworkRequest(authorId: authorId))

        authorRequest
            .subscribe(
                onNext: { [weak self] author in
                    self?.state.value = .idle(DataModel(
                        author: author,
                        contentRoot: author.workBlocks.makeWorkTree()
                    ))
                },
                onError: { [weak self] _ in
                    self?.state.value = .error
                }
            )
            .disposed(by: disposeBag)
    }
}
