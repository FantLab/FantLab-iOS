import Foundation
import UIKit
import ALLKit
import FantLabText

private final class TextViewContainer: UIView, UITextViewDelegate {
    let textView = UITextView()

    var openURL: ((URL) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        textView.clipsToBounds = false
        textView.isScrollEnabled = false
        textView.scrollsToTop = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.bounces = false
        textView.bouncesZoom = false
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.isExclusiveTouch = true
        textView.contentInset = .zero
        textView.contentInsetAdjustmentBehavior = .never
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.layoutManager.usesFontLeading = false
        textView.dataDetectorTypes = .link
        textView.delegate = self

        addSubview(textView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        textView.frame = bounds
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        openURL?(URL)

        return false
    }
}

struct StringLayoutModel {
    let string: NSAttributedString
    let linkAttributes: TextDecorator.Attributes
    let openURL: (URL) -> Void
}

final class StringLayoutSpec: ModelLayoutSpec<StringLayoutModel> {
    override func makeNodeFrom(model: StringLayoutModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let textNode = LayoutNode(sizeProvider: model.string, config: nil) { (view: TextViewContainer, _) in
            view.textView.linkTextAttributes = model.linkAttributes
            view.textView.attributedText = model.string
            view.openURL = model.openURL
        }

        let contentNode = LayoutNode(children: [textNode], config: { node in
            node.paddingLeft = 16
            node.paddingRight = 16
        })

        return contentNode
    }
}
