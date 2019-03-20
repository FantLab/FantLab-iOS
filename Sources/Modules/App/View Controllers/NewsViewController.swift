import Foundation
import UIKit
import RxSwift
import ALLKit
import FLUIKit
import FLWebAPI
import FLKit
import FLModels
import FLContentBuilders
import FLStyle
import FLLayoutSpecs

final class NewsViewController: ListViewController<NewsContentBuilder> {
    private let dataSource: PagedDataSource<NewsModel>

    init() {
        dataSource = PagedDataSource(loadObservable: { page -> Observable<[NewsModel]> in
            NetworkClient.shared.perform(request: NewsFeedNetworkRequest(page: page))
        })

        super.init(contentBuilder: NewsContentBuilder())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentBuilder.stateContentBuilder.errorContentBuilder.onRetry = { [weak self] in
            self?.dataSource.loadNextPage()
        }

        contentBuilder.onLastItemDisplay = { [weak self] in
            self?.dataSource.loadNextPage()
        }

        contentBuilder.onNewsTap = { news in
            AppRouter.shared.openNews(model: news)
        }

        scrollView.refreshControl = UIRefreshControl { [weak self] refresher in
            AppAnalytics.logNewsRefresh()

            self?.dataSource.loadFirstPage()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                refresher.endRefreshing()
            })
        }

        dataSource.stateObservable
            .map({ data -> NewsListViewState in
                NewsListViewState(
                    news: data.items,
                    state: data.state
                )
            })
            .subscribe(onNext: { [weak self] viewState in
                self?.apply(viewState: viewState)
            })
            .disposed(by: disposeBag)

        dataSource.loadFirstPage()
    }
}
