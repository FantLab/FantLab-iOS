import Foundation
import UIKit
import ALLKit
import FantLabUtils
import FantLabStyle
import FantLabText

public final class FLTextViewController: UIViewController {
    private let text: FLAttributedText

    public init(string: String) {
        self.text = FLAttributedText(
            taggedString: string,
            decorator: InteractiveTextDecorator(),
            replacementRules: TagReplacementRules.interactiveAttachments
        )

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public override func loadView() {
        view = UITextView()
    }

    private var textView: UITextView {
        return view as! UITextView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        textView.backgroundColor = AppStyle.colors.viewBackgroundColor
        textView.alwaysBounceVertical = true
        textView.isEditable = false
        textView.isSelectable = false // TODO: ???
        textView.dataDetectorTypes = []
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        textView.attributedText = text.string

        textView.all_addGestureRecognizer { [weak self] (gesture: UITapGestureRecognizer) in
            self?.onTap(gesture: gesture)
        }
    }

    private func onTap(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: textView)

        guard let range = textView.characterRange(at: location) else {
            return
        }

        let offset = textView.offset(from: textView.beginningOfDocument, to: range.start)

        guard let attachment = text.attachmentRanges.first(where: { $0.range.contains(offset) })?.attachment else {
            return
        }

        switch attachment {
        case .hiddenText(let text):
            showHiddenText(text, range: range)
        default:
            break // TODO:
        }
    }

    private func showHiddenText(_ text: String, range: UITextRange) {
        let vc = TextPopoverViewController(
            text: text,
            sourceView: textView,
            sourceRect: textView.firstRect(for: range)
        )

        present(vc, animated: true, completion: nil)
    }
}
