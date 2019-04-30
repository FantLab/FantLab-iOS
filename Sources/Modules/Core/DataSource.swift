import RxSwift
import RxRelay

public final class DataSource<T> {
    private let disposeBag = DisposeBag()
    private let internalState = BehaviorRelay<DataState<T>>(value: .initial)
    private let loadObservable: () -> Observable<T>

    public init(loadObservable: @escaping @autoclosure () -> Observable<T>) {
        self.loadObservable = loadObservable
    }

    public var state: DataState<T> {
        return internalState.value
    }

    public var stateObservable: Observable<DataState<T>> {
        return internalState.asObservable()
    }

    public func load() {
        if internalState.value.isLoading || internalState.value.isSuccess {
            return
        }

        internalState.accept(.loading)

        loadObservable()
            .subscribe(
                onNext: { [weak self] value in
                    self?.internalState.accept(.success(value))
                },
                onError: { [weak self] error in
                    self?.internalState.accept(.error(error))
                }
            )
            .disposed(by: disposeBag)
    }
}
