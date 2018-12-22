import Foundation
import UIKit

public final class CellSelection {
    private init() {}

    public static func alpha(cell: UICollectionViewCell, action: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1, animations: {
            cell.alpha = 0.3
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, animations: {
                cell.alpha = 1
            })

            action()
        })
    }

    public static func scale(cell: UICollectionViewCell, action: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1, animations: {
            cell.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, animations: {
                cell.transform = CGAffineTransform.identity
            })

            action()
        })
    }
}
