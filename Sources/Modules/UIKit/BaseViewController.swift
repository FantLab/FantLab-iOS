import Foundation
import UIKit
import RxSwift
import FLStyle

open class BaseViewController: UIViewController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return Appearance.statusBarStyle
    }

    // MARK: -

    public let disposeBag = DisposeBag()

    private let viewActiveSubject = ReplaySubject<Bool>.create(bufferSize: 1)

    public final var viewActive: Observable<Bool> {
        return viewActiveSubject
    }

    // MARK: -

    deinit {
        viewActiveSubject.onCompleted()
    }

    // MARK: -

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        viewActiveSubject.onNext(false)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewActiveSubject.onNext(true)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        viewActiveSubject.onNext(false)
    }
}
