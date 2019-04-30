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
