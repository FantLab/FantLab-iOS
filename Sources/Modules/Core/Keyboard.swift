import Foundation
import UIKit

public final class Keyboard: NSObject {
    public static let shared = Keyboard()

    private override init() {
        super.init()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handle(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handle(notification:)),
            name: UIResponder.keyboardDidChangeFrameNotification,
            object: nil
        )
    }

    @objc
    public private(set) dynamic var frame: CGRect = .zero

    // MARK: -

    @objc
    private func handle(notification: Notification) {
        guard let rect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        frame = rect
    }
}
