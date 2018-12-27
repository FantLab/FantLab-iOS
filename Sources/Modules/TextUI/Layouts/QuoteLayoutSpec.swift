import Foundation
import UIKit
import ALLKit

final class QuoteLayoutSpec: ModelLayoutSpec<NSAttributedString> {
    override func makeNodeFrom(model: NSAttributedString, sizeConstraints: SizeConstraints) -> LayoutNode {
        let drawing = model.drawing()

        let textNode = LayoutNode(sizeProvider: drawing, config: nil) { (label: AsyncLabel) in
            label.stringDrawing = drawing
        }

        let contentNode = LayoutNode(children: [textNode], config: { node in
            node.paddingLeft = 32
            node.paddingRight = 32
        })

        return contentNode
    }
}
