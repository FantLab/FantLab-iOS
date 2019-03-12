import Foundation
import UIKit

extension UIView {
    public func animated(action: @escaping () -> Void,
                         transform: CGAffineTransform = .init(scaleX: 0.95, y: 0.95)) {
        animated(
            action: action,
            { $0.transform = transform },
            { $0.transform = .identity },
            0.1,
            0.15
        )
    }

    public func animated(action: @escaping () -> Void, alpha: CGFloat) {
        animated(
            action: action,
            { $0.alpha = alpha },
            { $0.alpha = 1 },
            0.1,
            0.15
        )
    }

    public func animated(action: @escaping () -> Void,
                         _ a1: @escaping (UIView) -> Void,
                         _ a2: @escaping (UIView) -> Void,
                         _ d1: TimeInterval,
                         _ d2: TimeInterval) {
        UIApplication.shared.beginIgnoringInteractionEvents()

        UIView.animate(
            withDuration: d1,
            animations: { [weak self] in
                self.flatMap({
                    a1($0)
                })
            },
            completion: ({ _ in
                UIView.animate(
                    withDuration: d2,
                    animations: { [weak self] in
                        self.flatMap({
                            a2($0)
                        })
                    },
                    completion: ({ _ in
                        UIApplication.shared.endIgnoringInteractionEvents()
                    })
                )

                action()
            })
        )
    }
}
