import Foundation
import UIKit
import RxSwift

open class ImageBackedListViewController: ListViewController {
    private let viewActiveSubject = PublishSubject<Bool>()

    deinit {
        viewActiveSubject.onCompleted()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewActiveSubject.onNext(true)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        viewActiveSubject.onNext(false)
    }

    // MARK: -

    private lazy var imageVC: ImageBackgroundViewController? = parentVC()

    public final func setupWith(urlObservable: Observable<URL?>) {
        Observable.combineLatest(viewActiveSubject, urlObservable)
            .map({ (viewActive, url) -> URL? in
                return viewActive ? url : nil
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] imageURL in
                self?.imageVC?.imageURL = imageURL
            })
            .disposed(by: disposeBag)

        viewActiveSubject.onNext(false)
    }

    public final func updateImageVisibilityWith(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top

        imageVC?.moveTo(position: max(0, -offset) / 100)
    }
}
