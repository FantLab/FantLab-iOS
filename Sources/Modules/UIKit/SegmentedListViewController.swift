import Foundation
import UIKit
import RxSwift
import FLStyle
import FLKit
import PinIt

open class SegmentedListViewController<EnumType: Equatable & CaseIterable & CustomStringConvertible, BuilderType: ListContentBuilder>: ListViewController<BuilderType> {
    private let allCases: [EnumType]
    private let segmentControl: SegmentControl

    private let selectedSegmentSubject = ReplaySubject<EnumType>.create(bufferSize: 1)

    public var selectedSegmentObservable: Observable<EnumType> {
        return selectedSegmentSubject
    }

    deinit {
        selectedSegmentSubject.onCompleted()
    }

    public init(defaultValue: EnumType, contentBuilder: BuilderType) {
        allCases = Array(EnumType.allCases)
        segmentControl = SegmentControl(
            numberOfSegments: allCases.count,
            style: SegmentControl.Style(
                backgroundColor: UIColor.white,
                selectedBackgroundColor: Colors.darkOrange,
                borderColor: UIColor(rgb: 0xE2E2E2),
                textColor: UIColor(rgb: 0x757575),
                selectedTextColor: UIColor.white,
                font: Fonts.system.regular(size: 14)
            )
        )

        super.init(contentBuilder: contentBuilder)

        allCases.enumerated().forEach {
            segmentControl.set(title: $0.element.description, at: $0.offset)
        }

        segmentControl.selectedIndex = allCases.firstIndex(where: { $0 == defaultValue })!
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        setupSegmentedControl()

        valueChanged()
    }

    private func setupSegmentedControl() {
        scrollView.contentInset.top = 48

        scrollObservable.subscribe(onNext: { [weak self] offset in
            self?.isSortSelectionControlHidden = offset > -32
        }).disposed(by: disposeBag)

        segmentControl.onIndexChange = { [weak self] in
            self?.valueChanged()
        }

        view.addSubview(segmentControl)
        segmentControl.pin(.height).const(30).equal()
        segmentControl.pin(.top).to(topPanelView, .bottom).const(12).equal()
        segmentControl.pin(.left).to(view).const(12).equal()
        segmentControl.pin(.right).to(view).const(-12).equal()
    }

    private func valueChanged() {
        selectedSegmentSubject.onNext(allCases[segmentControl.selectedIndex])
    }

    private var isSortSelectionControlHidden: Bool = false {
        didSet {
            guard isSortSelectionControlHidden != oldValue else {
                return
            }

            let alpha: CGFloat = isSortSelectionControlHidden ? 0 : 1
            let transform: CGAffineTransform = isSortSelectionControlHidden ? CGAffineTransform(translationX: 0, y: -40) : .identity

            UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: { [segmentControl] in
                segmentControl.alpha = alpha
                segmentControl.transform = transform
            })
        }
    }
}
