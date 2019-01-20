import Foundation
import UIKit
import ALLKit
import yoga
import FantLabUtils
import FantLabStyle

public final class ListSectionTitleLayoutSpec: ModelLayoutSpec<(String, Int)> {
    public override func makeNodeFrom(model: (String, Int), sizeConstraints: SizeConstraints) -> LayoutNode {
        let titleString = model.0.attributed()
            .font(Fonts.system.bold(size: 16))
            .foregroundColor(UIColor.black)
            .make()

        let countString = String(model.1).attributed()
            .font(Fonts.system.regular(size: 13))
            .foregroundColor(UIColor.lightGray)
            .make()

        let titleNode = LayoutNode(sizeProvider: titleString, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = titleString
        }

        let countNode = LayoutNode(sizeProvider: countString, config: { node in
            node.marginLeft = 6
            node.marginBottom = 4
            node.isHidden = model.1 < 1
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = countString
        }

        let contentNode = LayoutNode(children: [titleNode, countNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: 12, left: 16, bottom: 16, right: 12)
        })

        return contentNode
    }
}
