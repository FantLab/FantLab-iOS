import Foundation
import UIKit
import RxSwift
import ALLKit
import FLUIKit
import FLStyle
import FLKit
import FLModels
import FLWebAPI
import FLContentBuilders

final class UserProfileViewController: ListViewController<DataStateContentBuilder<UserProfileContentBuilder>>, WebURLProvider {
    private let userId: Int
    private let dataSource: DataSource<UserProfileModel>

    init(userId: Int) {
        self.userId = userId

        do {
            let loadObservable = NetworkClient.shared.perform(request: GetUserProfileNetworkRequest(userId: userId))

            dataSource = DataSource(loadObservable: loadObservable)
        }

        super.init(contentBuilder: DataStateContentBuilder(dataContentBuilder: UserProfileContentBuilder()))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentBuilder.dataContentBuilder.onReviewsTap = { (userId, reviewsCount) in
            AppRouter.shared.openUserReviews(userId: userId, reviewsCount: reviewsCount)
        }

        contentBuilder.errorContentBuilder.onRetry = { [weak self] in
            self?.dataSource.load()
        }

        setupBackgroundImageWith(urlObservable: dataSource.stateObservable.map({ $0.data?.avatar }))

        dataSource.stateObservable
            .subscribe(onNext: { [weak self] state in
                self?.apply(viewState: state)
            })
            .disposed(by: disposeBag)

        dataSource.load()
    }

    // MARK: - WebURLProvider

    var webURL: URL? {
        return URL(string: "https://\(Hosts.portal)/user\(userId)")
    }
}
