import Foundation
import UIKit
import ALLKit
import yoga
import FantLabUtils
import FantLabStyle

public final class ItemSeparatorLayoutSpec: LayoutSpec {
    public override func makeNodeWith(sizeConstraints: SizeConstraints) -> LayoutNode {
        let separatorNode = LayoutNode(config: { node in
            node.height = YGValue(UIScreen.main.px)
        }) { (view: UIView) in
            view.backgroundColor = AppStyle.colors.separatorColor
        }

        let containerNode = LayoutNode(children: [separatorNode], config: { node in
            node.paddingLeft = 16
            node.paddingRight = 12
            node.height = 1
        })

        return containerNode
    }
}

public final class SectionSeparatorLayoutSpec: ModelLayoutSpec<Int> {
    public override func makeNodeFrom(model: Int, sizeConstraints: SizeConstraints) -> LayoutNode {
        let topLineNode = LayoutNode(config: { node in
            node.height = YGValue(UIScreen.main.px)
        }) { (view: UIView) in
            view.backgroundColor = AppStyle.colors.separatorColor
        }

        let backgroundNode = LayoutNode(config: { node in
            node.height = YGValue(integerLiteral: model)
        }) { (view: UIView) in
            view.backgroundColor = AppStyle.colors.sectionBackgroundColor
        }

        let bottomLineNode = LayoutNode(config: { node in
            node.height = YGValue(UIScreen.main.px)
        }) { (view: UIView) in
            view.backgroundColor = AppStyle.colors.separatorColor
        }

        return LayoutNode(children: [topLineNode, backgroundNode, bottomLineNode], config: { node in
            node.flexDirection = .column
        })
    }
}
