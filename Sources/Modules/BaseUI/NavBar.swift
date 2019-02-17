import Foundation
import UIKit
import FantLabUtils

public final class NavBarItem {
    let margin: CGFloat

    public init(margin: CGFloat = 12, _ makeView: @escaping () -> UIView) {
        self.margin = margin

        self.makeView = makeView
    }

    private let makeView: () -> UIView

    public private(set) lazy var view: UIView = makeView()
}

extension NavBarItem {
    public convenience init(margin: CGFloat = 12,
                            image: UIImage? = nil,
                            title: NSAttributedString? = nil,
                            contentEdgeInsets: UIEdgeInsets = .zero,
                            size: CGSize,
                            action: @escaping () -> Void) {
        self.init(margin: margin) {
            let button = UIButton(type: .system)
            button.setImage(image?.withRenderingMode(.alwaysTemplate), for: [])
            button.setAttributedTitle(title, for: [])
            button.contentEdgeInsets = contentEdgeInsets
            button.pin(.width).const(size.width).equal()
            button.pin(.height).const(size.height).equal()
            button.all_setEventHandler(for: .touchUpInside, action)
            return button
        }
    }
}

public protocol NavBar: class {
    var titleView: UIView? { get set }
    var leftItems: [NavBarItem] { get set }
    var rightItems: [NavBarItem] { get set }
}

extension NavBar {
    public func set(title: NSAttributedString?) {
        let label = (titleView as? UILabel) ?? UILabel(frame: .zero)
        label.numberOfLines = 0
        label.attributedText = title
        titleView = label
    }
}

final class NavBarView: UIView, NavBar {
    private class StackView: UIView {
        override class var layerClass: AnyClass {
            return CAShapeLayer.self
        }

        override var intrinsicContentSize: CGSize {
            return subviews.isEmpty ? .zero : super.intrinsicContentSize
        }
    }

    private let leftStack = StackView(frame: .zero)
    private let rightStack = StackView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true

        addSubview(leftStack)
        leftStack.pinEdges(to: self, right: .nan)

        addSubview(rightStack)
        rightStack.pinEdges(to: self, left: .nan)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: -

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 44)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard !bounds.isEmpty else {
            return
        }

        // it's ok

        titleViewWidthConstraint.flatMap {
            let sideOffset = max(leftStack.bounds.width, rightStack.bounds.width) + 12

            $0.constant = max(0, bounds.width - 2 * sideOffset)
        }
    }

    private var titleCenterYConstraint: NSLayoutConstraint?
    private var titleViewWidthConstraint: NSLayoutConstraint?

    // MARK: -

    var titleViewOffset: CGFloat = 0 {
        didSet {
            titleCenterYConstraint?.constant = titleViewOffset
        }
    }

    // MARK: -

    var titleView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()

            titleViewWidthConstraint = nil

            guard let titleView = titleView else {
                return
            }

            addSubview(titleView)

            titleView.pin(.centerX).to(self).equal()

            titleCenterYConstraint = titleView
                .pin(.centerY)
                .to(self)
                .const(titleViewOffset)
                .equal()

            titleViewWidthConstraint = titleView
                .pin(.width)
                .const(.greatestFiniteMagnitude)
                .lessThanOrEqual()

            layoutIfNeeded()
        }
    }

    var leftItems: [NavBarItem] = [] {
        didSet {
            leftStack.subviews.forEach { $0.removeFromSuperview() }

            leftItems.enumerated().forEach { (i, item) in
                let view = item.view

                leftStack.addSubview(view)

                view.pin(.centerY).to(leftStack).equal()

                if i == 0 {
                    view.pin(.left).to(leftStack).const(item.margin).equal()
                } else {
                    view.pin(.left).to(leftItems[i - 1].view, .right).const(item.margin).equal()
                }
            }

            leftItems.last?.view.pin(.right).to(leftStack).equal()

            layoutIfNeeded()
        }
    }

    var rightItems: [NavBarItem] = [] {
        didSet {
            rightStack.subviews.forEach { $0.removeFromSuperview() }

            rightItems.enumerated().forEach { (i, item) in
                let view = item.view

                rightStack.addSubview(view)

                view.pin(.centerY).to(rightStack).equal()

                if i == 0 {
                    view.pin(.right).to(rightStack).const(-item.margin).equal()
                } else {
                    view.pin(.right).to(rightItems[i - 1].view, .left).const(-item.margin).equal()
                }
            }

            rightItems.last?.view.pin(.left).to(rightStack).equal()

            layoutIfNeeded()
        }
    }
}
