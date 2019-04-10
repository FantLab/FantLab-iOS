import Foundation
import UIKit
import ALLKit
import RxSwift
import FLKit
import FLStyle
import FLModels
import FLUIKit
import FLLayoutSpecs
import FLContentBuilders
import FLWebAPI

final class EditionViewController: ListViewController<DataStateContentBuilder<EditionContentBuilder>>, WebURLProvider {
    private let dataSource: DataSource<EditionModel>

    init(editionId: Int) {
        do {
            let loadObservable = AppServices.network.perform(request: GetEditionNetworkRequest(editionId: editionId))

            dataSource = DataSource(loadObservable: loadObservable)
        }

        super.init(contentBuilder: DataStateContentBuilder(dataContentBuilder: EditionContentBuilder()))
    }

    init(isbn: String) {
        do {
            let loadObservable = AppServices.network.perform(request: ISBNEditionNetworkRequest(isbn: isbn)).flatMap({ editionId -> Observable<EditionModel> in
                AppServices.network.perform(request: GetEditionNetworkRequest(editionId: editionId))
            })

            dataSource = DataSource(loadObservable: loadObservable)
        }

        super.init(contentBuilder: DataStateContentBuilder(dataContentBuilder: EditionContentBuilder()))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Издание"

        contentBuilder.dataContentBuilder.onURLTap = { url in
            AppRouter.shared.openURL(url)
        }

        contentBuilder.errorContentBuilder.onRetry = { [weak self] in
            self?.dataSource.load()
        }

        setupBackgroundImageWith(urlObservable: dataSource.stateObservable.map({ $0.data?.biggestImageURL }))

        dataSource.stateObservable
            .subscribe(onNext: { [weak self] state in
                self?.apply(viewState: state)
            })
            .disposed(by: disposeBag)

        dataSource.load()
    }

    // MARK: - WebURLProvider

    var webURL: URL? {
        guard let data = dataSource.state.data else {
            return nil
        }

        return URL(string: "https://\(Hosts.portal)/edition\(data.id)")
    }
}
