import Foundation
import UIKit
import ALLKit
import FantLabUtils
import FantLabStyle

final class TextPopoverViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    private let string: NSAttributedString

    init(text: String, sourceView: UIView, sourceRect: CGRect) {
        string = text.attributed()
            .font(AppStyle.shared.fonts.regularFont(ofSize: 14))
            .foregroundColor(AppStyle.shared.colors.textMainColor)
            .lineSpacing(2)
            .make()

        super.init(nibName: nil, bundle: nil)

        preferredContentSize = CGSize(width: 300, height: 200)

        modalPresentationStyle = .popover

        popoverPresentationController.flatMap {
            $0.backgroundColor = AppStyle.shared.colors.viewBackgroundColor
            $0.delegate = self
            $0.permittedArrowDirections = .any
            $0.sourceView = sourceView
            $0.sourceRect = sourceRect
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: -

    override func loadView() {
        view = UITextView()
    }

    private var textView: UITextView {
        return view as! UITextView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.backgroundColor = AppStyle.shared.colors.viewBackgroundColor
        textView.isEditable = false
        textView.isSelectable = false
        textView.dataDetectorTypes = []
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.attributedText = string
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        textView.flashScrollIndicators()
    }

    // MARK: -

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
