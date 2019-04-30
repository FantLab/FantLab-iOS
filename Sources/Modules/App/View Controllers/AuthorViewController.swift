import Foundation
import UIKit
import ALLKit
import RxSwift
import RxRelay
import FLKit
import FLStyle
import FLModels
import FLUIKit
import FLContentBuilders
import FLWebAPI

final class AuthorViewController: ListViewController<DataStateContentBuilder<AuthorContentBuilder>>, AuthorContentBuilderDelegate, WebURLProvider {
    private struct DataModel {
        let author: AuthorModel
        let contentRoot: WorkTreeNode
    }

    private let authorId: Int
    private let dataSource: DataSource<DataModel>
    private let expandCollapseRelay = PublishRelay<Void>()

    init(authorId: Int) {
        self.authorId = authorId

        do {
            let loadObservable = AppServices.network.perform(request: GetAuthorNetworkRequest(authorId: authorId)).map({ author -> DataModel in
                DataModel(
                    author: author,
                    contentRoot: author.workBlocks.makeWorkTree()
                )
            })

            dataSource = DataSource(loadObservable: loadObservable)
        }

        super.init(contentBuilder: DataStateContentBuilder(dataContentBuilder: AuthorContentBuilder()))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""

        contentBuilder.dataContentBuilder.delegate = self

        contentBuilder.errorContentBuilder.onRetry = { [weak self] in
            self?.dataSource.load()
        }

        setupBackgroundImageWith(urlObservable: dataSource.stateObservable.map({ $0.data?.author.imageURL }))

        Observable.combineLatest(dataSource.stateObservable, expandCollapseRelay.asObservable())
            .map({ args -> DataState<AuthorViewState> in
                args.0.map({ data -> AuthorViewState in
                    return AuthorViewState(info: data.author, workTree: data.contentRoot)
                })
            })
            .subscribe(onNext: { [weak self] state in
                self?.apply(viewState: state)
            })
            .disposed(by: disposeBag)

        expandCollapseRelay.accept(())

        dataSource.load()
    }

    // MARK: - AuthorContentBuilderDelegate

    func onWebsitesTap(author: AuthorModel) {
        AppRouter.shared.openAuthorWebsites(author)
    }

    func onDescriptionTap(author: AuthorModel) {
        let string = [author.bio,
                      author.compiler,
                      author.notes].compactAndJoin("\n\n")

        AppRouter.shared.openText(title: "Биография", string: string, customHeaderListItems: []) { photoIndex -> URL in
            if photoIndex > 0 {
                return URL(string: "https://data.fantlab.ru/images/autors/\(author.id)_\(photoIndex)")!
            } else {
                return URL(string: "https://data.fantlab.ru/images/autors/\(author.id)")!
            }
        }
    }

    func onExpandOrCollapse() {
        expandCollapseRelay.accept(())
    }

    func onWorkTap(id: Int) {
        AppRouter.shared.openWork(id: id)
    }

    func onAwardsTap(author: AuthorModel) {
        AppRouter.shared.openAwards(author.awards)
    }

    func onURLTap(url: URL) {
        AppRouter.shared.openURL(url)
    }

    // MARK: - WebURLProvider

    var webURL: URL? {
        guard let data = dataSource.state.data else {
            return nil
        }

        return URL(string: "https://\(Hosts.portal)/autor\(data.author.id)")
    }
}
