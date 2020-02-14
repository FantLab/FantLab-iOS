import Foundation
import UIKit
import ALLKit

public final class FLTextQuoteLayoutSpec: ModelLayoutSpec<NSAttributedString> {
    public override func makeNodeFrom(model: NSAttributedString, sizeConstraints: SizeConstraints) -> LayoutNode {
        let drawing = model.drawing()

        let textNode = LayoutNode(sizeProvider: drawing, config: nil) { (label: AsyncLabel, _) in
            label.stringDrawing = drawing
        }

        let contentNode = LayoutNode(children: [textNode], {
            node.paddingLeft = 32
            node.paddingRight = 32
        })

        return contentNode
    }
}
