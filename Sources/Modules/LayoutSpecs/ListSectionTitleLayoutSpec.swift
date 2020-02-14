import Foundation
import UIKit
import ALLKit
import yoga
import FLKit
import FLStyle

public struct ListSectionTitleLayoutModel {
    public let title: String
    public let count: Int
    public let hasArrow: Bool

    public init(title: String,
                count: Int,
                hasArrow: Bool) {

        self.title = title
        self.count = count
        self.hasArrow = hasArrow
    }
}

public final class ListSectionTitleLayoutSpec: ModelLayoutSpec<ListSectionTitleLayoutModel> {
    public override func makeNodeFrom(model: ListSectionTitleLayoutModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let titleString = model.title.attributed()
            .font(Fonts.system.bold(size: 18))
            .foregroundColor(UIColor.black)
            .make()

        let countString: NSAttributedString?

        if model.count > 0 {
            countString = String(model.count).attributed()
                .font(Fonts.system.regular(size: 13))
                .foregroundColor(UIColor.lightGray)
                .make()
        } else {
            countString = nil
        }

        let titleNode = LayoutNode(sizeProvider: titleString, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = titleString
        }

        let countNode = LayoutNode(sizeProvider: countString, {
            node.marginLeft = 6
            node.marginBottom = 4
            node.isHidden = countString == nil
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = countString
        }

        let spacingNode: LayoutNode?
        let arrowNode: LayoutNode?

        if model.hasArrow {
            spacingNode = LayoutNode({
                node.flex = 1
            })

            arrowNode = LayoutNode({
                node.marginLeft = 8
                node.width = 10
                node.height = 10
            }) { (view: UIImageView, _) in
                view.contentMode = .scaleAspectFit
                view.tintColor = UIColor.lightGray
                view.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
            }
        } else {
            spacingNode = nil
            arrowNode = nil
        }

        let contentNode = LayoutNode(children: [titleNode, countNode, spacingNode, arrowNode], {
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: 12, left: 16, bottom: 16, right: 12)
        })

        return contentNode
    }
}
