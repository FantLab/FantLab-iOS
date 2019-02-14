import Foundation
import UIKit
import ALLKit
import RxSwift
import FantLabUtils
import FantLabStyle
import FantLabModels
import FantLabBaseUI
import FantLabContentBuilders
import FantLabWebAPI

final class AuthorViewController: ListViewController, AuthorContentBuilderDelegate, WebURLProvider {
    private struct DataModel {
        let author: AuthorModel
        let contentRoot: WorkTreeNode
    }

    private let authorId: Int
    private let state = ObservableValue<DataState<DataModel>>(.initial)
    private let expandCollapseSubject = PublishSubject<Void>()
    private let contentBuilder = DataStateContentBuilder(dataContentBuilder: AuthorContentBuilder())

    init(authorId: Int) {
        self.authorId = authorId

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    deinit {
        expandCollapseSubject.onCompleted()
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""

        contentBuilder.dataContentBuilder.delegate = self

        contentBuilder.errorContentBuilder.onRetry = { [weak self] in
            self?.loadAuthor()
        }

        setupBackgroundImageWith(urlObservable: state.observable().map({ $0.data?.author.imageURL }))

        setupStateMapping()

        loadAuthor()
    }

    // MARK: -

    private func setupStateMapping() {
        Observable.combineLatest(state.observable(), expandCollapseSubject)
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ [weak self] args -> [ListItem] in
                let dataModel = args.0.map({ data -> AuthorContentModel in
                    return (data.author, data.contentRoot)
                })

                return self?.contentBuilder.makeListItemsFrom(model: dataModel) ?? []
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.adapter.set(items: items)
            })
            .disposed(by: disposeBag)

        expandCollapseSubject.onNext(())
    }

    // MARK: -

    private func loadAuthor() {
        if state.value.isLoading || state.value.isIdle {
            return
        }

        state.value = .loading

        let authorRequest = NetworkClient.shared.perform(request: GetAuthorNetworkRequest(authorId: authorId))

        authorRequest
            .subscribe(
                onNext: { [weak self] author in
                    self?.state.value = .idle(DataModel(
                        author: author,
                        contentRoot: author.workBlocks.makeWorkTree()
                    ))
                },
                onError: { [weak self] error in
                    self?.state.value = .error(error)
                }
            )
            .disposed(by: disposeBag)
    }

    // MARK: - AuthorContentBuilderDelegate

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
        expandCollapseSubject.onNext(())
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
        guard let data = state.value.data else {
            return nil
        }

        return URL(string: "https://\(Hosts.portal)/autor\(data.author.id)")
    }
}
