import Foundation
import RxSwift
import RxRelay

extension BehaviorRelay {
    public func modify(value f: (inout Element) -> Void) {
        var x = value
        f(&x)
        accept(x)
    }
}

extension Reactive where Base: NotificationCenter {
    public func notification(_ name: Notification.Name?, object: AnyObject? = nil) -> Observable<Notification> {
        return Observable.create { [weak object, base] observer in
            let ncObserver = base.addObserver(forName: name, object: object, queue: nil) { notification in
                observer.onNext(notification)
            }

            return Disposables.create {
                base.removeObserver(ncObserver)
            }
        }
    }
}

extension Reactive where Base: NSObject {
    public func observe<Value>(_ keyPath: KeyPath<Base, Value>, options: NSKeyValueObservingOptions = [.initial, .new]) -> Observable<Value> {
        return Observable.create { [base] observer -> Disposable in
            let kvo = base.observe(keyPath, options: options) { (_, change) in
                change.newValue.flatMap(observer.onNext)
            }

            return Disposables.create {
                _ = kvo
            }
        }
    }
}
