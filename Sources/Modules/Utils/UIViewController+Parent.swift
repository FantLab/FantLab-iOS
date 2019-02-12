import UIKit

extension UIViewController {
    public func parentVC<T: UIViewController>() -> T? {
        return (parent as? T) ?? parent?.parentVC()
    }
}
