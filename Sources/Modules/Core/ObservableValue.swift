import Foundation
import RxSwift

public final class ObservableValue<T> {
    private let subject: BehaviorSubject<T>

    public init(_ value: T) {
        subject = BehaviorSubject(value: value)
    }

    deinit {
        subject.onCompleted()
    }

    public var value: T {
        get {
            return try! subject.value()
        }
        set {
            subject.onNext(newValue)
        }
    }

    public func observable() -> Observable<T> {
        return subject
    }
}
