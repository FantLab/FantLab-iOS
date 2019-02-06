import Foundation
import UIKit

public final class Alert {
    public struct Action {
        public let text: String
        public let perform: (() -> Void)?
    }

    public enum ActionType {
        case positive
        case negative
    }

    // MARK: -

    public init() {}

    public private(set) var title: String?
    public private(set) var subtitle: String?
    public private(set) var actions: [(Action, ActionType)] = []
    public private(set) var cancelAction: Action?

    // MARK: -
    @discardableResult
    public func set(title value: String?) -> Self {
        title = value

        return self
    }

    @discardableResult
    public func set(subtitle value: String?) -> Self {
        subtitle = value

        return self
    }

    @discardableResult
    public func set(cancelAction text: String, perform: (() -> Void)?) -> Self {
        cancelAction = Action(text: text, perform: perform)

        return self
    }

    @discardableResult
    public func add(positiveAction text: String, perform: (() -> Void)?) -> Self {
        actions.append((Action(text: text, perform: perform), .positive))

        return self
    }

    @discardableResult
    public func add(negativeAction text: String, perform: (() -> Void)?) -> Self {
        actions.append((Action(text: text, perform: perform), .negative))

        return self
    }
}

extension UIAlertController {
    public convenience init(alert: Alert, preferredStyle: UIAlertController.Style) {
        let alertStyle = UIDevice.current.userInterfaceIdiom == .phone ? preferredStyle : .alert

        self.init(title: alert.title, message: alert.subtitle, preferredStyle: alertStyle)

        alert.actions.forEach { (action, style) in
            let actionStyle: UIAlertAction.Style

            switch style {
            case .positive:
                actionStyle = .default
            case .negative:
                actionStyle = .destructive
            }

            addAction(UIAlertAction(title: action.text, style: actionStyle, handler: { _ in action.perform?() }))
        }

        alert.cancelAction.flatMap { action in
            addAction(UIAlertAction(title: action.text, style: .cancel, handler: { _ in action.perform?() }))
        }
    }
}
