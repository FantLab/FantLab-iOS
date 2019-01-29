import Foundation
import UIKit
import RxSwift
import FantLabStyle

open class BaseViewController: UIViewController {
    public let disposeBag = DisposeBag()

    private let viewActiveSubject = ReplaySubject<Bool>.create(bufferSize: 1)

    public final var viewActive: Observable<Bool> {
        return viewActiveSubject
    }

    deinit {
        viewActiveSubject.onCompleted()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

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
