import Foundation
import UIKit
import RxSwift

open class ImageBackedListViewController: ListViewController {
    private lazy var imageVC: ImageBackgroundViewController? = parentVC()

    public final func updateImageVisibilityWith(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top

        imageVC?.moveTo(position: max(0, -offset) / 100)
    }

    public final func setupWith(urlObservable: Observable<URL?>) {
        Observable.combineLatest(viewActive, urlObservable)
            .map({ (viewActive, url) -> URL? in
                return viewActive ? url : nil
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] imageURL in
                self?.imageVC?.imageURL = imageURL
            })
            .disposed(by: disposeBag)
    }
}
