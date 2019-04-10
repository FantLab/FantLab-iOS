import Foundation
import RxSwift

public final class PagedDataSource<T: IntegerIdProvider> {
    private let disposeBag = DisposeBag()
    private let internalState = ObservableValue(PagedDataState<T>(id: UUID().uuidString))
    private let loadObservable: (Int) -> Observable<[T]>

    public init(loadObservable: @escaping (Int) -> Observable<[T]>) {
        self.loadObservable = loadObservable
    }

    public var state: PagedDataState<T> {
        return internalState.value
    }

    public var stateObservable: Observable<PagedDataState<T>> {
        return internalState.observable()
    }

    public func loadFirstPage() {
        guard !internalState.value.state.isLoading else {
            return
        }

        internalState.value.state = .loading

        loadObservable(1)
            .subscribe(
                onNext: ({ [weak self] items in
                    var value = PagedDataState<T>(id: UUID().uuidString)

                    do {
                        var ids = value.ids

                        value.items = [items.filter({
                            ids.insert($0.intId).inserted
                        })]

                        value.ids = ids
                    }

                    value.page = 1
                    value.state = .success(())

                    self?.internalState.value = value
                }),
                onError: ({ [weak self] error in
                    var value = PagedDataState<T>(id: UUID().uuidString)
                    value.state = .error(error)

                    self?.internalState.value = value
                })
            )
            .disposed(by: disposeBag)
    }

    public func loadNextPage() {
        guard !internalState.value.state.isLoading && !internalState.value.isFull else {
            return
        }

        internalState.value.state = .loading

        let pageToLoad = internalState.value.page + 1

        loadObservable(pageToLoad)
            .subscribe(
                onNext: ({ [weak self] items in
                    guard let strongSelf = self else { return }

                    var value = strongSelf.internalState.value

                    if items.isEmpty {
                        value.isFull = true
                    } else {
                        var ids = value.ids

                        value.items.append(items.filter({
                            ids.insert($0.intId).inserted
                        }))

                        value.ids = ids
                    }

                    value.page = pageToLoad
                    value.state = .success(())

                    strongSelf.internalState.value = value
                }),
                onError: ({ [weak self] error in
                    guard let strongSelf = self else { return }

                    var value = strongSelf.internalState.value
                    value.state = .error(error)

                    strongSelf.internalState.value = value
                })
            )
            .disposed(by: disposeBag)
    }
}

public final class PagedComboDataSource<T: IntegerIdProvider> {
    private let disposeBag = DisposeBag()
    private let internalStateSubject = ReplaySubject<PagedDataState<T>>.create(bufferSize: 1)
    private let internalDataSource: ObservableValue<PagedDataSource<T>>

    deinit {
        internalStateSubject.onCompleted()
    }

    public init(dataSourceObservable: Observable<PagedDataSource<T>>) {
        internalDataSource = ObservableValue(PagedDataSource(loadObservable: { page -> Observable<[T]> in
            .just([])
        }))

        internalDataSource.observable()
            .flatMapLatest {
                $0.stateObservable
            }
            .subscribe(onNext: { [weak self] state in
                self?.internalStateSubject.onNext(state)
            })
            .disposed(by: disposeBag)

        dataSourceObservable
            .subscribe(onNext: { [weak self] dataSource in
                self?.internalDataSource.value = dataSource

                dataSource.loadFirstPage()
            })
            .disposed(by: disposeBag)
    }

    public var state: PagedDataState<T> {
        return internalDataSource.value.state
    }

    public var stateObservable: Observable<PagedDataState<T>> {
        return internalStateSubject
    }

    public func loadFirstPage() {
        internalDataSource.value.loadFirstPage()
    }

    public func loadNextPage() {
        internalDataSource.value.loadNextPage()
    }
}
