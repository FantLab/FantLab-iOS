import Foundation
import UIKit
import RxSwift
import ALLKit
import FantLabBaseUI
import FantLabContentBuilders
import FantLabUtils
import FantLabStyle
import FantLabModels
import FantLabWebAPI

final class FreshReviewsViewController: ListViewController {
    private struct DataModel {
        var reviews: [WorkReviewModel] = []
        var page: Int = 0
        var state: DataState<Void> = .initial
    }

    private let state = ObservableValue(DataModel(
        reviews: [],
        page: 0,
        state: .initial
    ))

    private let contentBuilder = WorkReviewsListContentBuilder(headerMode: WorkReviewHeaderMode.work)

    override func viewDidLoad() {
        super.viewDidLoad()

        contentBuilder.stateContentBuilder.errorContentBuilder.onRetry = { [weak self] in
            self?.loadNextPage()
        }

        contentBuilder.onLastItemDisplay = { [weak self] in
            self?.loadNextPage()
        }

        contentBuilder.singleReviewContentBuilder.onReviewUserTap = { userId in
            AppRouter.shared.openUserProfile(id: userId)
        }

        contentBuilder.singleReviewContentBuilder.onReviewWorkTap = { workId in
            AppRouter.shared.openWork(id: workId)
        }

        contentBuilder.singleReviewContentBuilder.onReviewTextTap = { review in
            AppRouter.shared.openReview(model: review, headerMode: .work)
        }

        setupStateMapping()

        do {
            let refresher = UIRefreshControl()
            refresher.all_setEventHandler(for: .valueChanged) { [weak self, weak refresher] in
                self?.refresh()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    refresher?.endRefreshing()
                })
            }

            adapter.collectionView.refreshControl = refresher
        }

        refresh()
    }

    // MARK: -

    private func setupStateMapping() {
        state.observable()
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .map { [weak self] data -> [ListItem] in
                return self?.contentBuilder.makeListItemsFrom(model: (data.reviews, data.state)) ?? []
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.adapter.set(items: items)
            })
            .disposed(by: disposeBag)
    }

    // MARK: -

    private func refresh() {
        guard !state.value.state.isLoading else {
            return
        }

        state.value.state = .loading

        let request = FreshReviewsNetworkRequest(page: 1)

        NetworkClient.shared.perform(request: request)
            .subscribe(
                onNext: ({ [weak self] reviews in
                    guard let strongSelf = self else { return }

                    strongSelf.state.value = DataModel(
                        reviews: reviews,
                        page: 1,
                        state: .idle(())
                    )
                }),
                onError: ({ [weak self] error in
                    guard let strongSelf = self else { return }

                    var value = strongSelf.state.value
                    value.state = .error(error)
                    strongSelf.state.value = value
                })
            )
            .disposed(by: disposeBag)
    }

    private func loadNextPage() {
        guard !state.value.state.isLoading else {
            return
        }

        state.value.state = .loading

        let pageToLoad = state.value.page + 1

        let request = FreshReviewsNetworkRequest(page: pageToLoad)

        NetworkClient.shared.perform(request: request)
            .subscribe(
                onNext: ({ [weak self] reviews in
                    guard let strongSelf = self else { return }

                    var value = strongSelf.state.value
                    value.reviews.append(contentsOf: reviews)
                    value.page = pageToLoad
                    value.state = .idle(())
                    strongSelf.state.value = value
                }),
                onError: ({ [weak self] error in
                    guard let strongSelf = self else { return }

                    var value = strongSelf.state.value
                    value.state = .error(error)
                    strongSelf.state.value = value
                })
            )
            .disposed(by: disposeBag)
    }
}
