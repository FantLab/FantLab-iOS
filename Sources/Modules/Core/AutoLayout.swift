import Foundation
import UIKit

public protocol AutoLayoutItem {
    func prepareForAutoLayout()
}

public final class LayoutConstraintBuilder {
    private let firstItem: AutoLayoutItem
    private let firstAttribute: NSLayoutConstraint.Attribute
    private var secondItem: AutoLayoutItem?
    private var secondAttribute: NSLayoutConstraint.Attribute?
    private var constant: CGFloat = 0
    private var multiplier: CGFloat = 1

    fileprivate init(_ item: AutoLayoutItem, _ attribute: NSLayoutConstraint.Attribute) {
        firstItem = item
        firstAttribute = attribute
    }

    public func to(_ item: AutoLayoutItem, _ attribute: NSLayoutConstraint.Attribute? = nil) -> Self {
        secondItem = item
        secondAttribute = attribute

        return self
    }

    public func const(_ value: CGFloat) -> Self {
        constant = value

        return self
    }

    public func multiply(by value: CGFloat) -> Self {
        multiplier = value

        return self
    }

    // MARK: -

    @discardableResult
    public func equal(priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return makeConstraint(relation: .equal, priority: priority)
    }

    @discardableResult
    public func lessThanOrEqual(priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return makeConstraint(relation: .lessThanOrEqual, priority: priority)
    }

    @discardableResult
    public func greaterThanOrEqual(priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return makeConstraint(relation: .greaterThanOrEqual, priority: priority)
    }

    // MARK: -

    private func makeConstraint(relation: NSLayoutConstraint.Relation, priority: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondItem != nil ? secondAttribute ?? firstAttribute : .notAnAttribute,
            multiplier: multiplier,
            constant: constant
        )

        constraint.priority = priority
        constraint.isActive = true

        return constraint
    }
}

extension UIView: AutoLayoutItem {
    public func prepareForAutoLayout() {
        translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UILayoutGuide: AutoLayoutItem {
    public func prepareForAutoLayout() {}
}

extension AutoLayoutItem {
    public func pin(_ attribute: NSLayoutConstraint.Attribute) -> LayoutConstraintBuilder {
        prepareForAutoLayout()

        return LayoutConstraintBuilder(self, attribute)
    }

    @discardableResult
    public func pinEdges(to item: AutoLayoutItem,
                         top: CGFloat = 0,
                         left: CGFloat = 0,
                         bottom: CGFloat = 0,
                         right: CGFloat = 0) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []

        if !top.isNaN { constraints.append(pin(.top).to(item).const(top).equal()) }
        if !left.isNaN { constraints.append(pin(.left).to(item).const(left).equal()) }
        if !bottom.isNaN { constraints.append(pin(.bottom).to(item).const(-bottom).equal()) }
        if !right.isNaN { constraints.append(pin(.right).to(item).const(-right).equal()) }

        return constraints
    }

    @discardableResult
    public func pinCenter(to item: AutoLayoutItem,
                          dx: CGFloat = 0,
                          dy: CGFloat = 0) -> [NSLayoutConstraint] {
        return [pin(.centerX).to(item).const(dx).equal(),
                pin(.centerY).to(item).const(dy).equal()]
    }
}
