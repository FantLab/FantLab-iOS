import Foundation
import UIKit
import RxSwift
import ALLKit
import FantLabWebAPI
import FantLabModels
import FantLabUtils
import FantLabStyle
import FantLabBaseUI
import FantLabLayoutSpecs

final class SearchViewController: ListViewController, UISearchResultsUpdating {
    private let searchSubject = PublishSubject<String>()

    deinit {
        searchSubject.onCompleted()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "FantLab"

        view.backgroundColor = UIColor.white

        do {
            definesPresentationContext = true

            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Поиск"

            Appearance.setup(searchBar: searchController.searchBar)

            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        }

        do {
            searchSubject
                .debounce(0.5, scheduler: MainScheduler.instance)
                .flatMapLatest({ searchText -> Observable<[WorkPreviewModel]> in
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

    private func makeListItemsFrom(searchResults: [WorkPreviewModel]) -> [ListItem] {
        var items: [ListItem] = []

        searchResults.forEach { workModel in
            let id = String(workModel.id)

            let item = ListItem(
                id: id,
                layoutSpec: WorkPreviewLayoutSpec(model: workModel)
            )

            item.didSelect = { [weak self] cell, _ in
                CellSelection.scale(cell: cell, action: {
                    self?.openWork(id: workModel.id)
                })
            }

            items.append(item)

            items.append(ListItem(id: id + "_sep", layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)))
        }

        return items
    }

    private func openWork(id: Int) {
        AppRouter.shared.openWork(id: id)
    }
}
