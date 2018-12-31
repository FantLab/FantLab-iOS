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
        }) { (view: UIView, _) in
            view.backgroundColor = model.0
        }
    }
}

public final class ItemSeparatorLayoutSpec: ModelLayoutSpec<UIColor> {
    public override func makeNodeFrom(model: UIColor, sizeConstraints: SizeConstraints) -> LayoutNode {
        let separatorNode = LayoutNode(config: { node in
            node.height = YGValue(UIScreen.main.px)
        }) { (view: UIView, _) in
            view.backgroundColor = model
        }

        let containerNode = LayoutNode(children: [separatorNode], config: { node in
            node.paddingLeft = 16
            node.paddingRight = 12
            node.height = 1
        })

        return containerNode
    }
  }
