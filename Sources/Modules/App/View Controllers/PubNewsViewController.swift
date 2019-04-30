import Foundation
import UIKit
import RxSwift
import RxRelay
import ALLKit
import FLUIKit
import FLWebAPI
import FLKit
import FLModels
import FLContentBuilders
import FLStyle
import FLLayoutSpecs

final class PubNewsViewController: SegmentedListViewController<PubNewsType, PagedDataStateContentBuilder<PubNewsModel, PubNewsContentBuilder>>, NavBarItemsProvider {
    private let dataSource: PagedComboDataSource<PubNewsModel>
    private let typeRelay = PublishRelay<PubNewsType>()
    private let sortRelay = BehaviorRelay(value: PubNewsSort.popularity)
    private let langRelay = PublishRelay<PubNewsLang>()

    init() {
        do {
            let dataSourceObservable = Observable.combineLatest(
                typeRelay.asObservable().distinctUntilChanged(),
                sortRelay.asObservable().distinctUntilChanged(),
                langRelay.asObservable().distinctUntilChanged()).map { (pubType, sortType, lang) -> PagedDataSource<PubNewsModel> in
                PagedDataSource(loadObservable: { page -> Observable<[PubNewsModel]> in
                    AppServices.network.perform(request: PubNewsNetworkRequest(requestType: pubType, lang: lang, sort: sortType, page: page))
                })
            }

            dataSource = PagedComboDataSource(dataSourceObservable: dataSourceObservable)
        }

        super.init(defaultValue: .pubnews, contentBuilder: PagedDataStateContentBuilder(itemsContentBuilder: PubNewsContentBuilder()))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let segmentControl = SegmentControl(
                numberOfSegments: 2,
                style: SegmentControl.Style(
                    backgroundColor: Colors.fantasticBlue,
                    selectedBackgroundColor: UIColor.white,
                    borderColor: UIColor.white,
                    textColor: UIColor.white,
                    selectedTextColor: Colors.fantasticBlue,
                    font: Fonts.system.regular(size: 16)
                )
            )
            segmentControl.set(title: "🇷🇺", at: 0)
            segmentControl.set(title: "🌎", at: 1)

            segmentControl.pin(.height).const(30).equal()
            segmentControl.pin(.width).const(96).equal()

            navBar.titleView = segmentControl

            segmentControl.onIndexChange = { [weak self, weak segmentControl] in
                guard let selectedIndex = segmentControl?.selectedIndex else {
                    return
                }

                switch selectedIndex {
                case 0:
                    self?.langRelay.accept(.ru)
                case 1:
                    self?.langRelay.accept(.other)
                default:
                    break
                }

            }
        }

        contentBuilder.stateContentBuilder.errorContentBuilder.onRetry = { [weak self] in
            self?.dataSource.loadNextPage()
        }

        contentBuilder.onLastItemDisplay = { [weak self] in
            self?.dataSource.loadNextPage()
        }

        contentBuilder.itemsContentBuilder.onURLTap = { url in
            AppRouter.shared.openURL(url)
        }

        contentBuilder.itemsContentBuilder.onEditionTap = { editionId in
            AppRouter.shared.openEdition(id: editionId)
        }

        scrollView.refreshControl = UIRefreshControl { [weak self] refresher in
            self?.dataSource.loadFirstPage()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                refresher.endRefreshing()
            })
        }

        selectedSegmentObservable
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] pubType in
                self?.typeRelay.accept(pubType)
            })
            .disposed(by: disposeBag)

        dataSource.stateObservable
            .subscribe(onNext: { [weak self] viewState in
                self?.apply(viewState: viewState)
            })
            .disposed(by: disposeBag)

        langRelay.accept(.ru)

        dataSource.loadFirstPage()
    }

    // MARK: -

    private func showSortPicker() {
        let alert = Alert().set(title: "Сортировать по:")

        let currentSort = sortRelay.value

        PubNewsSort.allCases.forEach { sort in
            if sort == currentSort {
                alert.add(positiveAction: "\(sort.description) ✓", perform: nil)
            } else {
                alert.add(positiveAction: sort.description, perform: { [weak self] in
                    self?.sortRelay.accept(sort)
                })
            }
        }

        alert.set(cancelAction: "Отмена") {}

        let vc = UIAlertController(alert: alert, preferredStyle: .actionSheet)

        present(vc, animated: true, completion: nil)
    }

    // MARK: -

    var leftItems: [NavBarItem] {
        return []
    }

    var rightItems: [NavBarItem] {
        let sortItem = NavBarItem(
            margin: 0,
            image: UIImage(named: "sort"),
            contentEdgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
            size: CGSize(width: 40, height: 40),
            action: ({ [weak self] in
                self?.showSortPicker()
            })
        )

        return [sortItem]
    }
}
