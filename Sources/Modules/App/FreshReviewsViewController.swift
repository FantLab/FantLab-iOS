import Foundation
import UIKit
import RxSwift
import ALLKit
import FLUIKit
import FLContentBuilders
import FLKit
import FLStyle
import FLModels
import FLWebAPI

final class FreshReviewsViewController: ListViewController<WorkReviewsListContentBuilder> {
    private let dataSource: PagedDataSource<WorkReviewModel>

    init() {
        dataSource = PagedDataSource(loadObservable: { page -> Observable<[WorkReviewModel]> in
            NetworkClient.shared.perform(request: FreshReviewsNetworkRequest(page: page))
        })

        super.init(contentBuilder: WorkReviewsListContentBuilder(headerMode: .userAndWork, useSectionSeparatorStyle: true))
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

        contentBuilder.singleReviewContentBuilder.onReviewUserTap = { userId in
            AppRouter.shared.openUserProfile(id: userId)
        }

        contentBuilder.singleReviewContentBuilder.onReviewWorkTap = { workId in
            AppRouter.shared.openWork(id: workId)
        }

        contentBuilder.singleReviewContentBuilder.onReviewTextTap = { review in
            AppRouter.shared.openReview(model: review, headerMode: .userAndWork)
        }

        scrollView.refreshControl = UIRefreshControl { [weak self] refresher in
            AppAnalytics.logFreshReviewsRefresh()

            self?.dataSource.loadFirstPage()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                refresher.endRefreshing()
            })
        }

        dataSource.stateObservable
            .map({ data -> WorkReviewsListViewState in
                WorkReviewsListViewState(
                    reviews: data.items,
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
