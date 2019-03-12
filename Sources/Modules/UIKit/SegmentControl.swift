import Foundation
import UIKit
import ALLKit

public final class SegmentControl: UIView {
    public struct Style {
        public let backgroundColor: UIColor
        public let selectedBackgroundColor: UIColor
        public let borderColor: UIColor
        public let textColor: UIColor
        public let selectedTextColor: UIColor
        public let font: UIFont

        public init(backgroundColor: UIColor,
                    selectedBackgroundColor: UIColor,
                    borderColor: UIColor,
                    textColor: UIColor,
                    selectedTextColor: UIColor,
                    font: UIFont) {

            self.backgroundColor = backgroundColor
            self.selectedBackgroundColor = selectedBackgroundColor
            self.borderColor = borderColor
            self.textColor = textColor
            self.selectedTextColor = selectedTextColor
            self.font = font
        }
    }

    private struct Consts {
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 5
    }

    private let numberOfSegments: Int
    private let style: Style

    private var normalLabels: [UILabel] = []
    private var selectedLabels: [UILabel] = []

    private let selectionView = UIView()

    public init(numberOfSegments: Int, style: Style) {
        precondition(numberOfSegments > 1)

        self.numberOfSegments = numberOfSegments
        self.style = style

        super.init(frame: .zero)

        clipsToBounds = true
        layer.cornerRadius = Consts.cornerRadius

        do {
            selectionView.backgroundColor = UIColor.white
        }

        do {
            normalLabels = (0..<numberOfSegments).map { index -> UILabel in
                let label = UILabel()
                label.font = style.font
                label.backgroundColor = style.backgroundColor
                label.textColor = style.textColor
                label.textAlignment = .center

                if index < numberOfSegments - 1 {
                    let separator = UIView()
                    separator.backgroundColor = style.borderColor

                    label.addSubview(separator)

                    separator.pinEdges(to: label, left: .nan)
                    separator.pin(.width).const(Consts.borderWidth).equal()
                }

                return label
            }

            let stackView = UIStackView(arrangedSubviews: normalLabels)
            stackView.alignment = .fill
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually

            addSubview(stackView)

            stackView.pinEdges(to: self)
        }

        do {
            let borderView = UIView()
            borderView.layer.borderWidth = Consts.borderWidth
            borderView.layer.borderColor = style.borderColor.cgColor
            borderView.layer.cornerRadius = Consts.cornerRadius

            addSubview(borderView)

            borderView.pinEdges(to: self)
        }

        do {
            selectedLabels = (0..<numberOfSegments).map { _ -> UILabel in
                let label = UILabel()
                label.font = style.font
                label.backgroundColor = style.selectedBackgroundColor
                label.textColor = style.selectedTextColor
                label.textAlignment = .center

                return label
            }

            let stackView = UIStackView(arrangedSubviews: selectedLabels)
            stackView.alignment = .fill
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually

            let stackContainer = UIView()
            stackContainer.mask = selectionView
            stackContainer.addSubview(stackView)
            stackView.pinEdges(to: stackContainer)
            addSubview(stackContainer)
            stackContainer.pinEdges(to: self)
        }

        do {
            all_addGestureRecognizer { [weak self] (tap: UITapGestureRecognizer) in
                self?.handle(tap)
            }

            all_addGestureRecognizer { [weak self] (pan: UIPanGestureRecognizer) in
                self?.handle(pan)
            }
        }

        defer {
            selectionViewPosition = 0
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        updateSelectionViewPosition()
    }

    // MARK: -
    public var selectedIndex: Int {
        get {
            return Int(selectionViewPosition)
        }
        set {
            guard newValue >= 0 && newValue < numberOfSegments else {
                return
            }

            selectionViewPosition = CGFloat(newValue)
        }
    }

    public var onIndexChange: (() -> Void)?

    public func set(title: String, at index: Int) {
        guard index >= 0 && index < numberOfSegments else {
            return
        }

        normalLabels[index].text = title
        selectedLabels[index].text = title
    }

    // MARK: -
    private var selectionViewPosition: CGFloat = 0 {
        didSet {
            updateSelectionViewPosition()
        }
    }

    private func updateSelectionViewPosition() {
        guard !bounds.isEmpty else {
            return
        }

        let size = bounds.width / CGFloat(numberOfSegments)
        let width = size + 2 * Consts.borderWidth
        let x = selectionViewPosition * size - Consts.borderWidth

        selectionView.frame = CGRect(x: x, y: 0, width: width, height: bounds.height)
    }

    private func animatePositionTo(value: CGFloat, shouldNotify: Bool) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: { [weak self] in
            self?.selectionViewPosition = value
        }) { [weak self] finished in
            if finished && shouldNotify {
                self?.onIndexChange?()
            }
        }
    }

    // MARK: -
    private func handle(_ tap: UITapGestureRecognizer) {
        let location = tap.location(in: self)

        let position = (location.x / bounds.width * CGFloat(numberOfSegments)).rounded(.down)

        animatePositionTo(value: position, shouldNotify: true)
    }

    private var startLocation: CGFloat = 0

    private func handle(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            startLocation = selectionView.frame.minX
        case .changed:
            let location = startLocation + pan.translation(in: self).x

            let position = location / bounds.width * CGFloat(numberOfSegments)

            selectionViewPosition = max(0, min(CGFloat(numberOfSegments - 1), position))
        default:
            animatePositionTo(value: selectionViewPosition.rounded(), shouldNotify: true)
        }
    }
}
