import Foundation
import UIKit
import RxSwift
import ALLKit
import FantLabBaseUI
import FantLabWebAPI
import FantLabUtils
import FantLabModels
import FantLabContentBuilders
import FantLabStyle

final class NewsViewController: ListViewController {
    private let state = ObservableValue<DataState<[NewsModel]>>(.initial)
    private let contentBuilder = DataStateContentBuilder(dataContentBuilder: NewsContentBuilder())

    override func viewDidLoad() {
        super.viewDidLoad()

        contentBuilder.dataContentBuilder.onURLTap = { url in
            AppRouter.shared.openURL(url, entersReaderIfAvailable: true)
        }

        adapter.collectionView.contentInset.top = 16
        adapter.collectionView.showsVerticalScrollIndicator = false

        setupStateMapping()

        do {
            let refresher = UIRefreshControl()
            refresher.all_setEventHandler(for: .valueChanged) { [weak self, weak refresher] in
                self?.loadNews()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    refresher?.endRefreshing()
                })
            }

            adapter.collectionView.refreshControl = refresher
        }

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
