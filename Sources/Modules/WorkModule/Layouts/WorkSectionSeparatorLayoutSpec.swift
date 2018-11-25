import Foundation
import UIKit
import ALLKit
import yoga
import FantLabUtils
import FantLabStyle

final class WorkSectionSeparatorLayoutSpec: LayoutSpec {
    override func makeNode() -> LayoutNode {
        let separatorNode = LayoutNode(children: [], config: { node in
            node.height = YGValue(1.0/UIScreen.main.scale)
        }) { (view: UIView, _) in
            view.backgroundColor = AppStyle.shared.colors.separatorColor
        }

        let containerNode = LayoutNode(children: [separatorNode], config: { node in
            node.paddingLeft = 16
            node.paddingRight = 16
        })

        return containerNode
    }
}
