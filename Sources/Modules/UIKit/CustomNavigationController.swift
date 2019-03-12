import Foundation
import UIKit

public final class CustomNavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    public var willShowVC: ((UIViewController) -> Void)?

    public override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBarHidden(true, animated: false)

        view.backgroundColor = UIColor.white
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }

    // MARK: -

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === interactivePopGestureRecognizer else {
            return false
        }

        return viewControllers.count > 1
    }

    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        willShowVC?(viewController)
    }
}
