import Foundation
import UIKit
import RxSwift
import ALLKit
import FantLabSharedUI
import FantLabWebAPI
import FantLabModels
import FantLabUtils
import FantLabStyle

final class SearchViewController: ListViewController, UISearchResultsUpdating {
    private let disposeBag = DisposeBag()
    private let searchSubject = PublishSubject<String>()

    deinit {
        searchSubject.onCompleted()
    }

    var openWork: ((Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "FantLab"

        view.backgroundColor = UIColor.white

        do {
            definesPresentationContext = true

            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Поиск произведений"

            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        }

        do {
            searchSubject
                .debounce(0.5, scheduler: MainScheduler.instance)
                .flatMapLatest({ searchText -> Observable<SearchResultsModel> in
                    return NetworkClient.shared.perform(request: MainSearchNetworkRequest(searchText: searchText))
                })
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .map({ [weak self] searchResults -> [ListItem] in
                    return self?.makeListItemsFrom(searchResults: searchResults) ?? []
                })
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] listItems in
                    self?.adapter.set(items: listItems)
                })
                .disposed(by: disposeBag)
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        searchSubject.onNext(searchController.searchBar.text ?? "")
    }

    // MARK: -

    private func makeListItemsFrom(searchResults: SearchResultsModel) -> [ListItem] {
        var items: [ListItem] = []

        searchResults.works.forEach { workModel in
            let id = String(workModel.id)

            let item = ListItem(
                id: id,
                layoutSpec: SearchResultsWorkLayoutSpec(model: workModel)
            )

            item.didSelect = { [weak self] _ in
                self?.openWork?(workModel.id)
            }

            items.append(item)

            items.append(ListItem(id: id + "_sep", layoutSpec: ItemSeparatorLayoutSpec()))
        }

        return items
    }
}

private final class SearchResultsWorkLayoutSpec: ModelLayoutSpec<SearchResultsModel.WorkModel> {
    override func makeNodeFrom(model: SearchResultsModel.WorkModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let string = model.name.attributed()
            .font(Fonts.system.medium(size: 15))
            .foregroundColor(UIColor.black)
            .make()

        let textNode = LayoutNode(sizeProvider: string, config: { node in
            node.margin(all: 16)
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = string
        }

        return LayoutNode(children: [textNode])
    }
}
