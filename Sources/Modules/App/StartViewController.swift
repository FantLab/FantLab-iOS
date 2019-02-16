import Foundation
import UIKit
import RxSwift
import ALLKit
import FantLabBaseUI
import FantLabWebAPI
import FantLabUtils
import FantLabModels
import FantLabContentBuilders

final class StartViewController: ListViewController {
    private let state = ObservableValue<DataState<[NewsModel]>>(.initial)
    private let contentBuilder = DataStateContentBuilder(dataContentBuilder: NewsContentBuilder())

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Новости"

        contentBuilder.dataContentBuilder.onURLTap = { url in
            AppRouter.shared.openURL(url, entersReaderIfAvailable: true)
        }

        setupStateMapping()

        loadNews()
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

    private func loadNews() {
        if state.value.isLoading || state.value.isIdle {
            return
        }

        state.value = .loading

        NetworkClient.shared.perform(request: NewsFeedNetworkRequest())
            .subscribe(
                onNext: { [weak self] news in
                    self?.state.value = .idle(news)
                },
                onError: { [weak self] error in
                    self?.state.value = .error(error)
                }
            )
            .disposed(by: disposeBag)
    }
}
