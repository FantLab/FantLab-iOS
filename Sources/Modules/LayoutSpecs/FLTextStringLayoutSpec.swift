import Foundation
import UIKit
import ALLKit
import FLKit
import FLText

private final class RichTextView: UIView {
    var onURLTap: ((URL) -> Void)?

    var textStack: InteractiveTextStack! {
        didSet {
            let size = bounds.size

            DispatchQueue.global().async { [weak self] in
                let image = self?.textStack.render(size: size)

                DispatchQueue.main.async {
                    self?.layer.contents = image?.cgImage
                }
            }
        }
    }

    // MARK: -

    private lazy var selectionLayer = CAShapeLayer()

    private func linkRangeFrom(touch: UITouch?) -> InteractiveTextStack.LinkRange? {
        guard let point = touch?.location(in: self), let characterIndex = textStack.characterIndexAt(point: point) else {
            return nil
        }

        return textStack.linkRangeAt(characterIndex: characterIndex)
    }

    // MARK: -

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let linkRange = linkRangeFrom(touch: touches.first) else {
            super.touchesBegan(touches, with: event)

            return
        }

        if selectionLayer.superlayer == nil {
            layer.addSublayer(selectionLayer)

            selectionLayer.frame = bounds
            selectionLayer.fillColor = UIColor.black.withAlphaComponent(0.3).cgColor
        }

        selectionLayer.path = textStack.selectionPathFor(glyphRange: linkRange.range).cgPath
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let linkRange = linkRangeFrom(touch: touches.first) else {
            selectionLayer.path = nil

            super.touchesEnded(touches, with: event)

            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.selectionLayer.path = nil

            self?.onURLTap?(linkRange.url)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectionLayer.path = nil

        super.touchesCancelled(touches, with: event)
    }
}

public struct FLTextStringLayoutModel {
    public let string: NSAttributedString
    public let linkAttributes: TextDecorator.Attributes
    public let openURL: (URL) -> Void

    public init(string: NSAttributedString,
                linkAttributes: TextDecorator.Attributes,
                openURL: @escaping (URL) -> Void) {

        self.string = string
        self.linkAttributes = linkAttributes
        self.openURL = openURL
    }
}

public final class FLTextStringLayoutSpec: ModelLayoutSpec<FLTextStringLayoutModel> {
    public override func makeNodeFrom(model: FLTextStringLayoutModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let textStack = InteractiveTextStack(string: model.string, linkAttribute: FLText.linkAttribute)

        let textNode = LayoutNode(sizeProvider: textStack, config: nil) { (view: RichTextView, _) in
            view.onURLTap = model.openURL
            view.textStack = textStack
        }

        let contentNode = LayoutNode(children: [textNode], {
            node.paddingLeft = 16
            node.paddingRight = 16
        })

        return contentNode
    }
}
