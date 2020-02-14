import Foundation
import UIKit
import ALLKit
import FLModels
import FLKit
import FLStyle

public final class AwardTitleLayoutSpec: ModelLayoutSpec<AwardPreviewModel> {
    public override func makeNodeFrom(model: AwardPreviewModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString: NSAttributedString

        do {
            nameString = (model.rusName.nilIfEmpty ?? model.name).attributed()
                .font(Fonts.system.medium(size: 15))
                .foregroundColor(UIColor.black)
                .make()
        }

        let iconNode = LayoutNode({
            node.width = 24
            node.height = 24
        }) { (imageView: UIImageView, _) in
            imageView.contentMode = .scaleAspectFit

            WebImage.load(url: model.iconURL, into: imageView)
        }

        let nameNode = LayoutNode(sizeProvider: nameString, {
            node.marginLeft = 16
            node.flex = 1
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let topNode = LayoutNode(children: [iconNode, nameNode], {
            node.flexDirection = .row
            node.alignItems = .center
        })

        let contentNode = LayoutNode(children: [topNode], {
            node.flexDirection = .column
            node.padding(all: 16)
        })

        return contentNode
    }
}
