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

final class EditionViewController: ListViewController, WebURLProvider {
    private let state = ObservableValue<DataState<EditionModel>>(.initial)
    private let loadEditionObservable: Observable<EditionModel>
    private let contentBuilder = DataStateContentBuilder(dataContentBuilder: EditionContentBuilder())

    init(editionId: Int) {
        loadEditionObservable = NetworkClient.shared.perform(request: GetEditionNetworkRequest(editionId: editionId))

        super.init(nibName: nil, bundle: nil)
    }

    init(isbn: String) {
        loadEditionObservable = NetworkClient.shared.perform(request: ISBNEditionNetworkRequest(isbn: isbn)).flatMap({ editionId -> Observable<EditionModel> in
            NetworkClient.shared.perform(request: GetEditionNetworkRequest(editionId: editionId))
        })

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Издание"

        contentBuilder.dataContentBuilder.onURLTap = { [weak self] url in
            self?.open(url: url)
        }

        contentBuilder.errorContentBuilder.onRetry = { [weak self] in
            self?.loadEdition()
        }

        setupBackgroundImageWith(urlObservable: state.observable().map({ $0.data?.biggestImageURL }))

        setupStateMapping()

        loadEdition()
    }

    // MARK: -

    private func setupStateMapping() {
        state.observable()
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ [weak self] state -> [ListItem] in
                return self?.contentBuilder.makeListItemsFrom(model: state) ?? []
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.adapter.set(items: items)
            })
            .disposed(by: disposeBag)
    }

    private func loadEdition() {
        if state.value.isLoading || state.value.isIdle {
            return
        }

        state.value = .loading

        loadEditionObservable
            .subscribe(
                onNext: { [weak self] edition in
                    self?.state.value = .idle(edition)
                },
                onError: { [weak self] error in
                    self?.state.value = .error(error)
                }
            )
            .disposed(by: disposeBag)
    }

    private func open(url: URL) {
        AppRouter.shared.openURL(url)
    }

    // MARK: - WebURLProvider

    var webURL: URL? {
        guard let data = state.value.data else {
            return nil
        }

        return URL(string: "https://\(Hosts.portal)/edition\(data.id)")
    }
}
