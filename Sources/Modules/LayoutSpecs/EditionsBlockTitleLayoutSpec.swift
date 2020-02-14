import Foundation
import UIKit
import ALLKit
import FLModels
import FLStyle

public struct EditionsBlockTitleLayoutModel {
    public let title: String
    public let count: Int

    public init(title: String,
                count: Int) {

        self.title = title
        self.count = count
    }
}

public final class EditionsBlockTitleLayoutSpec: ModelLayoutSpec<EditionsBlockTitleLayoutModel> {
    public override func makeNodeFrom(model: EditionsBlockTitleLayoutModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let titleString = model.title.attributed()
            .font(Fonts.system.bold(size: 20))
            .foregroundColor(UIColor.black)
            .make()

        let countString: NSAttributedString?

        if model.count > 0 {
            countString = String(model.count).attributed()
                .font(Fonts.system.regular(size: 16))
                .foregroundColor(UIColor.lightGray)
                .make()
        } else {
            countString = nil
        }

        let titleNode = LayoutNode(sizeProvider: titleString, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = titleString
        }

        let spacingNode = LayoutNode({
            node.flex = 1
        })

        let countNode = LayoutNode(sizeProvider: countString, {
            node.marginLeft = 8
        }) { (label: UILabel, _) in
            label.attributedText = countString
        }

        let contentNode = LayoutNode(children: [titleNode, spacingNode, countNode], {
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(all: 16)
        })

        return contentNode
    }
}
