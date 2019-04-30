import Foundation
import RxSwift
import RxRelay

public final class FileStorage<ModelType: Codable> {
    private let disposeBag = DisposeBag()
    private let fileURL: URL
    private let buffer: BehaviorRelay<ModelType>

    public init(fileName: String, defaultValue: ModelType) {
        fileURL = URL(fileURLWithPath: FileUtils.docDir, isDirectory: true).appendingPathComponent(fileName, isDirectory: false)

        do {
            let data = try Data(contentsOf: fileURL)
            let initialValue = try JSONDecoder().decode(ModelType.self, from: data)

            buffer = BehaviorRelay(value: initialValue)
        } catch {
            buffer = BehaviorRelay(value: defaultValue)
        }

        buffer.asObservable()
            .debounce(.seconds(1), scheduler: SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [weak self] value in
                try? self?.save(value: value)
            })
            .disposed(by: disposeBag)
    }

    private func save(value: ModelType) throws {
        let data = try JSONEncoder().encode(value)
        try data.write(to: fileURL, options: .atomicWrite)
    }

    // MARK: -

    public var value: ModelType {
        get {
            return buffer.value
        }
        set {
            buffer.accept(newValue)
        }
    }

    public func observable() -> Observable<ModelType> {
        return buffer.asObservable()
    }
}
