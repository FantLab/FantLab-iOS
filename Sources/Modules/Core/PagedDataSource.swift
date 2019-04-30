import Foundation
import RxSwift
import RxRelay

public final class PagedDataSource<T: IntegerIdProvider> {
    private let disposeBag = DisposeBag()
    private let internalState = BehaviorRelay(value: PagedDataState<T>(id: UUID().uuidString))
    private let loadObservable: (Int) -> Observable<[T]>

    public init(loadObservable: @escaping (Int) -> Observable<[T]>) {
        self.loadObservable = loadObservable
    }

    public var state: PagedDataState<T> {
        return internalState.value
    }

    public var stateObservable: Observable<PagedDataState<T>> {
        return internalState.asObservable()
    }

    public func loadFirstPage() {
        guard !internalState.value.state.isLoading else {
            return
        }

        internalState.modify {
            $0.state = .loading
        }

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

                    self?.internalState.accept(value)
                }),
                onError: ({ [weak self] error in
                    var value = PagedDataState<T>(id: UUID().uuidString)
                    value.state = .error(error)

                    self?.internalState.accept(value)
                })
            )
            .disposed(by: disposeBag)
    }

    public func loadNextPage() {
        guard !internalState.value.state.isLoading && !internalState.value.isFull else {
            return
        }

        do {
            var value = internalState.value
            value.state = .loading
            internalState.accept(value)
        }

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

                    strongSelf.internalState.accept(value)
                }),
                onError: ({ [weak self] error in
                    guard let strongSelf = self else { return }

                    var value = strongSelf.internalState.value
                    value.state = .error(error)

                    strongSelf.internalState.accept(value)
                })
            )
            .disposed(by: disposeBag)
    }
}

public final class PagedComboDataSource<T: IntegerIdProvider> {
    private let disposeBag = DisposeBag()
    private let internalStateSubject = ReplaySubject<PagedDataState<T>>.create(bufferSize: 1)
    private let internalDataSource: BehaviorRelay<PagedDataSource<T>>

    public init(dataSourceObservable: Observable<PagedDataSource<T>>) {
        internalDataSource = BehaviorRelay(value: PagedDataSource(loadObservable: { page -> Observable<[T]> in
            .just([])
        }))

        internalDataSource.asObservable()
            .flatMapLatest {
                $0.stateObservable
            }
            .subscribe(onNext: { [weak self] state in
                self?.internalStateSubject.onNext(state)
            })
            .disposed(by: disposeBag)

        dataSourceObservable
            .subscribe(onNext: { [weak self] dataSource in
                self?.internalDataSource.accept(dataSource)

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
