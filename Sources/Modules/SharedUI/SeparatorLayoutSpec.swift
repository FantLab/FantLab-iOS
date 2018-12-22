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
            view.backgroundColor = UIColor(rgb: 0xBCBBC1)
        }

        let containerNode = LayoutNode(children: [separatorNode], config: { node in
            node.paddingLeft = 16
            node.paddingRight = 12
            node.height = 1
        })

        return containerNode
    }
}

public final class SectionSeparatorLayoutSpec: ModelLayoutSpec<(String, Int)> {
    public override func makeNodeFrom(model: (String, Int), sizeConstraints: SizeConstraints) -> LayoutNode {
        let topLineNode = LayoutNode(config: { node in
            node.height = YGValue(UIScreen.main.px)
        }) { (view: UIView) in
            view.backgroundColor = UIColor(rgb: 0xE2E2E2)
        }

        let bottomLineNode = LayoutNode(config: { node in
            node.height = YGValue(UIScreen.main.px)
        }) { (view: UIView) in
            view.backgroundColor = UIColor(rgb: 0xE2E2E2)
        }

        let titleString = model.0.attributed()
            .font(Fonts.system.bold(size: 15))
            .foregroundColor(UIColor.black)
            .make()

        let titleNode = LayoutNode(sizeProvider: titleString, config: { node in
            node.flex = 1
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = titleString
        }

        let backgroundNode = LayoutNode(children: [titleNode], config: { node in
            node.padding(top: 12, left: 16, bottom: 12, right: 12)
            node.minHeight = YGValue(integerLiteral: model.1)
        }) { (view: UIView) in
            view.backgroundColor = UIColor(rgb: 0xF3F3F3)
        }

        let contentNode = LayoutNode(children: [topLineNode, backgroundNode, bottomLineNode], config: { node in
            node.flexDirection = .column
        })

        return contentNode
    }
}
