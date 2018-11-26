import Foundation
import UIKit
import ALLKit
import FantLabStyle

open class ListViewController: UIViewController {
    public let adapter = CollectionViewAdapter()

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppStyle.shared.colors.viewBackgroundColor

        adapter.collectionView.backgroundColor = AppStyle.shared.colors.viewBackgroundColor
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

        adapter.set(boundingSize: BoundingSize(width: bounds.width, height: .nan))
    }
}
