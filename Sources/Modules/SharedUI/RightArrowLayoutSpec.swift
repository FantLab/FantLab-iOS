import Foundation
import UIKit
import ALLKit
import FantLabStyle

public final class RightArrowLayoutSpec: ModelLayoutSpec<LayoutSpec> {
    public override func makeNodeFrom(model: LayoutSpec) -> LayoutNode {
        let contentNode = LayoutNode(children: [model.makeNode()], config: { node in
            node.flex = 1
        })

        let imageNode = LayoutNode(children: [], config: { node in
            node.marginRight = 16
            node.marginLeft = 8
            node.width = 12
            node.height = 12
        }) { (view: UIImageView, _) in
            view.contentMode = .scaleAspectFit
            view.tintColor = AppStyle.shared.colors.arrowColor
            view.image = UIImage(named: "right-arrow")?.withRenderingMode(.alwaysTemplate)
        }

        let stackNode = LayoutNode(children: [contentNode, imageNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
        })

        return stackNode
    }
}
