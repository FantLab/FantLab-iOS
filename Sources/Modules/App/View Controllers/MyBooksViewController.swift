import Foundation
import UIKit
import RxSwift
import ALLKit
import FLUIKit
import FLModels
import FLContentBuilders
import FLKit
import FLWebAPI

final class MyBooksViewController: SegmentedListViewController<MyBookModel.Group, MyBooksContentBuilder> {
    private let dataSource: PagedComboDataSource<WorkPreviewModel>
    private let selectedGroupSubject = PublishSubject<MyBookModel.Group>()
    private let removeIdSubject = PublishSubject<Int>()

    deinit {
        selectedGroupSubject.onCompleted()
        removeIdSubject.onCompleted()
    }

    init() {
        do {
            let dataSourceObservable = selectedGroupSubject
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .map { group -> PagedDataSource<WorkPreviewModel> in
                    let items = MyBookService.shared.itemsIn(group: group).sorted(by: {
                        $0.date > $1.date
                    })

                    return PagedDataSource(loadObservable: { page -> Observable<[WorkPreviewModel]> in
                        let pageSize = 10

                        let workIds = items.dropFirst((page - 1) * pageSize).prefix(pageSize).map({ $0.id })

                        guard !workIds.isEmpty else {
                            return .just([])
                        }

                        return NetworkClient.shared.perform(request: GetWorksByIdsNetworkRequest(workIds: workIds))
                    })
            }

            dataSource = PagedComboDataSource(dataSourceObservable: dataSourceObservable)
        }

        super.init(defaultValue: .wantToRead, contentBuilder: MyBooksContentBuilder())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            contentBuilder.onWorkTap = { workId in
                AppRouter.shared.openWork(id: workId)
            }

            contentBuilder.onWorkDeleteTap = { [weak self] workId in
                self?.removeIdSubject.onNext(workId)
            }

            contentBuilder.onFirstSwipeDisplay = { [weak self] swipeView in
                self?.toggleSwipe(swipeView)
            }

            contentBuilder.stateContentBuilder.errorContentBuilder.onRetry = { [weak self] in
                self?.dataSource.loadNextPage()
            }

            contentBuilder.onLastItemDisplay = { [weak self] in
                self?.dataSource.loadNextPage()
            }
        }

        do {
            Observable.combineLatest(viewActive, selectedSegmentObservable.distinctUntilChanged())
                .subscribe(onNext: { [weak self] viewActive, group in
                    if viewActive {
                        self?.selectedGroupSubject.onNext(group)
                    }
                })
                .disposed(by: disposeBag)

            removeIdSubject
                .subscribe(onNext: MyBookService.shared.remove)
                .disposed(by: disposeBag)

            let removedIdsObservable = selectedGroupSubject
                .flatMapLatest({ [removeIdSubject] _ -> Observable<Set<Int>> in
                    return removeIdSubject
                        .scan(into: Set<Int>(), accumulator: { (idSet, newId) in
                            idSet.insert(newId)
                        })
                        .startWith([])
                })

            let dataObservable = dataSource.stateObservable

            Observable.combineLatest(dataObservable, removedIdsObservable)
                .observeOn(MainScheduler.instance)
                .map { (data, removedIds) -> MyBooksViewState in
                    MyBooksViewState(
                        works: data.items.filter({
                            !removedIds.contains($0.id)
                        }),
                        state: data.state
                    )
                }
                .subscribe(onNext: { [weak self] viewState in
                    self?.apply(viewState: viewState)
                })
                .disposed(by: disposeBag)
        }

        dataSource.loadFirstPage()
    }

    override func sizeConstraintsFromView(bounds: CGRect) -> SizeConstraints {
        return SizeConstraints(width: bounds.width, height: bounds.height - scrollView.contentInset.top)
    }

    // MARK: -

    private func toggleSwipe(_ swipeView: SwipeViewPublicInterface) {
        let key = "swipe_demo_was_shown"

        guard !UserDefaults.standard.bool(forKey: key) else {
            return
        }

        UserDefaults.standard.set(true, forKey: key)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            UIApplication.shared.beginIgnoringInteractionEvents()

            swipeView.open(animated: true)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                swipeView.close(animated: true)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            })
        })
    }
}
