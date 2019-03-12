import Foundation
import UIKit

extension UIColor {
    public convenience init(rgb: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255,
            blue: CGFloat(rgb & 0x0000FF) / 255,
            alpha: alpha
        )
    }
}

extension UIScreen {
    public var px: CGFloat {
        return 1.0/scale
    }
}

extension UIViewController {
    public func parentVC<T: UIViewController>() -> T? {
        return (parent as? T) ?? parent?.parentVC()
    }
}

extension UIImage {
    public func with(orientation: UIImage.Orientation) -> UIImage? {
        return cgImage.flatMap {
            UIImage(cgImage: $0, scale: scale, orientation: orientation)
        }
    }
}

extension UIRefreshControl {
    public convenience init(action: @escaping (UIRefreshControl) -> Void) {
        self.init()

        all_setEventHandler(for: .valueChanged) { [weak self] in
            self.flatMap({
                action($0)
            })
        }
    }
}
