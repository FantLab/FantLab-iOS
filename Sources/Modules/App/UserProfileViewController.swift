import Foundation
import UIKit
import RxSwift
import ALLKit
import FantLabBaseUI
import FantLabStyle
import FantLabUtils
import FantLabModels
import FantLabWebAPI
import FantLabContentBuilders

final class UserProfileViewController: ImageBackedListViewController, WebURLProvider {
    private let userId: Int
    private let state = ObservableValue<DataState<UserProfileModel>>(.initial)
    private let contentBuilder = DataStateContentBuilder(dataContentBuilder: UserProfileContentBuilder())

    init(userId: Int) {
        self.userId = userId

        super.init(nibName: nil, bundle: nil)
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
            self?.loadUserProfile()
        }

        setupUI()
        setupStateMapping()

        loadUserProfile()
    }

    // MARK: -

    private func setupUI() {
        setupBackgroundImageWith(urlObservable: state.observable().map({ $0.data?.avatar }))

        adapter.scrollEvents.didScroll = { [weak self] scrollView in
            self?.updateImageVisibilityWith(scrollView: scrollView)
        }
    }

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

    private func loadUserProfile() {
        if state.value.isLoading || state.value.isIdle {
            return
        }

        state.value = .loading

        NetworkClient.shared.perform(request: GetUserProfileNetworkRequest(userId: userId))
            .subscribe(
                onNext: { [weak self] userProfile in
                    self?.state.value = .idle(userProfile)
                },
                onError: { [weak self] error in
                    self?.state.value = .error(error)
                }
            )
            .disposed(by: disposeBag)
    }

    // MARK: - WebURLProvider

    var webURL: URL? {
        return URL(string: "https://\(Hosts.portal)/user\(userId)")
    }
}
