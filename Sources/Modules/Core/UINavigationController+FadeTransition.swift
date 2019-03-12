import Foundation
import UIKit

extension UINavigationController {
    public func popWithFadeAnimation() {
        view.layer.add(makeFadeTransition(), forKey: nil)
        _ = popViewController(animated: false)
    }

    public func pushWithFadeAnimation(viewController: UIViewController) {
        view.layer.add(makeFadeTransition(), forKey: nil)
        pushViewController(viewController, animated: false)
    }

    private func makeFadeTransition() -> CATransition {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .fade
        return transition
    }
}
