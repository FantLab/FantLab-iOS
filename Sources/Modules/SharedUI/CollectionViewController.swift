import Foundation
import UIKit
import ALLKit
import FantLabStyle

open class ListViewController: UIViewController {
    public let adapter = CollectionViewAdapter()

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppStyle.colors.viewBackgroundColor

        adapter.collectionView.backgroundColor = AppStyle.colors.viewBackgroundColor
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
