import Foundation
import UIKit
import ALLKit
import RxSwift
import FantLabUtils
import FantLabStyle
import FantLabModels
import FantLabBaseUI

final class AuthorViewController: ImageBackedListViewController {
    private let interactor: AuthorInteractor
    private let contentBuilder = AuthorContentBuilder()
    private let expandCollapseSubject = PublishSubject<Void>()

    init(authorId: Int) {
        interactor = AuthorInteractor(authorId: authorId)

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

        // content builder setup

        do {
            contentBuilder.onExpandOrCollapse = { [weak self] in
                self?.expandCollapseSubject.onNext(())
            }

            contentBuilder.onDescriptionTap = { [weak self] author in
                self?.openDescriptionAndNotes(author: author)
            }

            contentBuilder.onAwardsTap = { [weak self] author in
                self?.openAwards(author: author)
            }

            contentBuilder.onChildWorkTap = { [weak self] workId in
                self?.openWork(id: workId)
            }

            contentBuilder.onURLTap = { [weak self] url in
                self?.open(url: url)
            }
        }

        // image background

        do {
            setupWith(urlObservable: interactor.stateObservable.map({ state -> URL? in
                if case let .idle(data) = state {
                    return data.author.imageURL
                }

                return nil
            }))

            adapter.scrollEvents.didScroll = { [weak self] scrollView in
                self?.updateImageVisibilityWith(scrollView: scrollView)
            }
        }

        // state

        do {
            Observable.combineLatest(interactor.stateObservable, expandCollapseSubject)
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .map({ [weak self] args -> [ListItem] in
                    return self?.contentBuilder.makeListItemsFrom(state: args.0) ?? []
                })
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] items in
                    self?.adapter.set(items: items)
                })
                .disposed(by: disposeBag)

            expandCollapseSubject.onNext(())

            interactor.loadAuthor()
        }

        // share

        do {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        }
    }

    // MARK: -

    private func openWork(id: Int) {
        AppRouter.shared.openWork(id: id)
    }

    private func openAwards(author model: AuthorModel) {
        AppRouter.shared.openAwards(model.awards)
    }

    private func openDescriptionAndNotes(author model: AuthorModel) {
        let string = [model.bio,
                    model.compiler,
                    model.notes].compactAndJoin("\n\n")

        AppRouter.shared.openText(title: "Биография", string: string, customHeaderListItems: []) { photoIndex -> URL in
            if photoIndex > 0 {
                return URL(string: "https://data.fantlab.ru/images/autors/\(model.id)_\(photoIndex)")!
            } else {
                return URL(string: "https://data.fantlab.ru/images/autors/\(model.id)")!
            }
        }
    }

    private func open(url: URL) {
        AppRouter.shared.openURL(url)
    }

    @objc
    private func share() {
        guard let url = interactor.authorURL else {
            return
        }

        AppRouter.shared.share(url: url)
    }
}
