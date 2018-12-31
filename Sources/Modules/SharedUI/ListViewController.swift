import Foundation
import UIKit
import RxSwift
import ALLKit
import FantLabStyle

open class ListViewController: UIViewController {
    public let disposeBag = DisposeBag()

    public let adapter = CollectionViewAdapter()

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        adapter.collectionView.backgroundColor = UIColor.white
        adapter.collectionView.alwaysBounceVertical = true
        view.addSubview(adapter.collectionView)
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let bounds = view.bounds

        guard !bounds.isEmpty else {
            return
        }

        adapter.collectionView.frame = bounds

        adapter.set(sizeConstraints: SizeConstraints(width: bounds.width, height: .nan))
    }
}
