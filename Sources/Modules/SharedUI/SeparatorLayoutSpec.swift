import Foundation
import UIKit
import ALLKit
import yoga
import FantLabUtils
import FantLabStyle

public final class EmptySpaceLayoutSpec: ModelLayoutSpec<(UIColor, Int)> {
    public override func makeNodeFrom(model: (UIColor, Int), sizeConstraints: SizeConstraints) -> LayoutNode {
        return LayoutNode(config: { node in
            node.height = YGValue(CGFloat(model.1))
        }) { (view: UIView) in
            view.backgroundColor = model.0
        }
    }
}

public final class ItemSeparatorLayoutSpec: LayoutSpec {
    public override func makeNodeWith(sizeConstraints: SizeConstraints) -> LayoutNode {
        let separatorNode = LayoutNode(config: { node in
            node.height = YGValue(UIScreen.main.px)
        }) { (view: UIView) in
            view.backgroundColor = UIColor(rgb: 0xC8C7CC)
        }

        let containerNode = LayoutNode(children: [separatorNode], config: { node in
            node.paddingLeft = 16
            node.paddingRight = 12
            node.height = 1
        })

        return containerNode
    }
}
