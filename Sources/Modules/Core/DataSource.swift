import RxSwift

public final class DataSource<T> {
    private let disposeBag = DisposeBag()
    private let internalState = ObservableValue<DataState<T>>(.initial)
    private let loadObservable: () -> Observable<T>

    public init(loadObservable: @escaping @autoclosure () -> Observable<T>) {
        self.loadObservable = loadObservable
    }

    public var state: DataState<T> {
        return internalState.value
    }

    public var stateObservable: Observable<DataState<T>> {
        return internalState.observable()
    }

    public func load() {
        if internalState.value.isLoading || internalState.value.isSuccess {
            return
        }

        internalState.value = .loading

        loadObservable()
            .subscribe(
                onNext: { [weak self] value in
                    self?.internalState.value = .success(value)
                },
                onError: { [weak self] error in
                    self?.internalState.value = .error(error)
                }
            )
            .disposed(by: disposeBag)
    }
}
