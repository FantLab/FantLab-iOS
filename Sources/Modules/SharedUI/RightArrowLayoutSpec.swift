import Foundation
import UIKit
import ALLKit
import FantLabStyle

public final class RightArrowLayoutSpec: ModelLayoutSpec<LayoutNode> {
    public override func makeNodeFrom(model: LayoutNode, sizeConstraints: SizeConstraints) -> LayoutNode {
        let contentNode = LayoutNode(children: [model], config: { node in
            node.flex = 1
        })

        let imageNode = LayoutNode(config: { node in
            node.marginLeft = 8
            node.marginRight = 2
            node.width = 12
            node.height = 12
        }) { (view: UIImageView) in
            view.contentMode = .scaleAspectFit
            view.tintColor = AppStyle.colors.arrowColor
            view.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
        }

        let stackNode = LayoutNode(children: [contentNode, imageNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: 16, left: 16, bottom: 16, right: 8)
        })

        return stackNode
    }
}
