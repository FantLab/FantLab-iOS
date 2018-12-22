import Foundation
import UIKit
import ALLKit
import yoga
import FantLabUtils
import FantLabStyle
import FantLabSharedUI

final class WorkSectionTitleLayoutSpec: ModelLayoutSpec<(String, Int)> {
    override func makeNodeFrom(model: (String, Int), sizeConstraints: SizeConstraints) -> LayoutNode {
        let titleString = model.0.attributed()
            .font(Fonts.system.bold(size: 17))
            .foregroundColor(UIColor.black)
            .make()

        let countString = String(model.1).attributed()
            .font(Fonts.system.regular(size: 13))
            .foregroundColor(UIColor.lightGray)
            .make()

        let titleNode = LayoutNode(sizeProvider: titleString, config: nil) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = titleString
        }

        let countNode = LayoutNode(sizeProvider: countString, config: { node in
            node.marginLeft = 6
            node.marginBottom = 4
            node.isHidden = model.1 < 2
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = countString
        }

        let contentNode = LayoutNode(children: [titleNode, countNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: 12, left: 16, bottom: 12, right: 16)
        })

        return contentNode
    }
}
