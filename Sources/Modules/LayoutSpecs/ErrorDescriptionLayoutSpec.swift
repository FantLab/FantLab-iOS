import Foundation
import UIKit
import ALLKit
import FLKit
import FLStyle

public final class ErrorDescriptionLayoutSpec: ModelLayoutSpec<(UIImage, String)> {
    public override func makeNodeFrom(model: (UIImage, String), sizeConstraints: SizeConstraints) -> LayoutNode {
        let string = model.1.attributed()
            .font(Fonts.system.regular(size: 15))
            .foregroundColor(UIColor.lightGray)
            .alignment(.center)
            .make()

        let textNode = LayoutNode(sizeProvider: string, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = string
        }

        let imageNode = LayoutNode({
            node.width = 100
            node.height = 100
            node.marginBottom = 24
        }) { (view: UIImageView, _) in
            view.image = model.0
            view.contentMode = .scaleAspectFit
        }

        let contentNode = LayoutNode(children: [imageNode, textNode], {
            node.padding(top: 32, left: 16, bottom: 32, right: 16)
            node.flexDirection = .column
            node.alignItems = .center
        })

        return contentNode
    }
}
