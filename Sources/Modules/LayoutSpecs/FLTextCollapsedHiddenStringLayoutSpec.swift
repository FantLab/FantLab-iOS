import Foundation
import UIKit
import ALLKit
import FantLabStyle

public final class FLTextCollapsedHiddenStringLayoutSpec: ModelLayoutSpec<String> {
    public override func makeNodeFrom(model: String, sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString = model.attributed()
            .font(Fonts.system.bold(size: 14))
            .foregroundColor(UIColor.black)
            .make()

        let showContentString = "Показать".attributed()
            .font(Fonts.system.medium(size: 17))
            .foregroundColor(Colors.flOrange)
            .make()

        let nameTextNode = LayoutNode(sizeProvider: nameString, config: { node in
            node.marginBottom = 4
            node.marginLeft = 8
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let showContentNode = LayoutNode(sizeProvider: showContentString, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = showContentString
        }

        let borderNode = LayoutNode(children: [showContentNode], config: { node in
            node.padding(all: 16)
            node.flexDirection = .column
            node.alignItems = .center
            node.alignSelf = .stretch
        }) { (view: UIView, _) in
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.backgroundColor = Colors.perfectGray
        }

        let contentNode = LayoutNode(children: [nameTextNode, borderNode], config: { node in
            node.paddingLeft = 16
            node.paddingRight = 16
            node.flexDirection = .column
            node.alignItems = .flexStart
        })

        return contentNode
    }
}
