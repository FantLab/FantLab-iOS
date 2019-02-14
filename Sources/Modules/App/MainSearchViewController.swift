import Foundation
import UIKit
import Vision
import RxSwift
import ALLKit
import FantLabWebAPI
import FantLabModels
import FantLabUtils
import FantLabStyle
import FantLabBaseUI
import FantLabLayoutSpecs
import FantLabContentBuilders

final class MainSearchViewController: SearchViewController {
    private let contentBuilder = DataStateContentBuilder(dataContentBuilder: SearchResultContentBuilder())

    override func viewDidLoad() {
        super.viewDidLoad()

        contentBuilder.dataContentBuilder.onAuthorTap = { [weak self] id in
            self?.openAuthor(id: id)
        }

        contentBuilder.dataContentBuilder.onWorkTap = { [weak self] id in
            self?.openWork(id: id)
        }

        contentBuilder.errorContentBuilder.onRetry = { [weak self] in
            self?.triggerSearch()
        }

        placeholderText = "Поиск авторов и произведений"

        setupStateMapping()
    }

    // MARK: -

    private func setupStateMapping() {
        let loadingObservable: Observable<DataState<MainSearchResult>> = searchTextObservable.map({ _ in DataState<MainSearchResult>.loading })

        let dataObservable: Observable<DataState<MainSearchResult>> = searchTextObservable
            .debounce(0.5, scheduler: MainScheduler.instance)
            .flatMapLatest({ searchText -> Observable<DataState<MainSearchResult>> in
                return NetworkClient.shared.perform(request: MainSearchNetworkRequest(searchText: searchText))
                    .map({ DataState<MainSearchResult>.idle($0) })
                    .catchError({ error -> Observable<DataState<MainSearchResult>> in
                        return .just(DataState<MainSearchResult>.error(error))
                    })
            })

        Observable.merge(loadingObservable, dataObservable)
            .distinctUntilChanged({ (x, y) -> Bool in
                return x.isLoading && y.isLoading
            })
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ [weak self] state -> [ListItem] in
                let dataModel = state.map({ result -> SearchResultContentModel in
                    (result.authors, result.works)
                })

                return self?.contentBuilder.makeListItemsFrom(model: dataModel) ?? []
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] listItems in
                self?.adapter.set(items: listItems)
            })
            .disposed(by: disposeBag)
    }

    // MARK: -

    private func openAuthor(id: Int) {
        AppRouter.shared.openAuthor(id: id)
    }

    private func openWork(id: Int) {
        AppRouter.shared.openWork(id: id)
    }
}
