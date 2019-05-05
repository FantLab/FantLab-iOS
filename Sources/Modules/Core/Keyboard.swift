import Foundation
import UIKit
import RxSwift
import RxRelay

public final class Keyboard {
    private let disposeBag = DisposeBag()
    private let frameRelay = BehaviorRelay<CGRect>(value: .zero)

    // MARK: -

    private static let keyboard = Keyboard(.default)

    private init(_ nc: NotificationCenter) {
        Observable
            .merge(
                nc.rx.notification(UIResponder.keyboardWillChangeFrameNotification),
                nc.rx.notification(UIResponder.keyboardDidChangeFrameNotification)
            )
            .map { notification -> CGRect in
                return (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
            }
            .bind(to: frameRelay)
            .disposed(by: disposeBag)
    }

    // MARK: -

    public static var frame: CGRect {
        return keyboard.frameRelay.value
    }

    public static var frameObservable: Observable<CGRect> {
        return keyboard.frameRelay.asObservable()
    }
}
