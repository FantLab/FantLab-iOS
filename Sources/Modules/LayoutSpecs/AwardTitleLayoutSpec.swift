import Foundation
import UIKit
import ALLKit
import YYWebImage
import FantLabModels
import FantLabUtils
import FantLabStyle

public final class AwardTitleLayoutSpec: ModelLayoutSpec<AwardPreviewModel> {
    public override func makeNodeFrom(model: AwardPreviewModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString: NSAttributedString

        do {
            nameString = (model.rusName.nilIfEmpty ?? model.name).attributed()
                .font(Fonts.system.medium(size: 15))
                .foregroundColor(UIColor.black)
                .make()
        }

        let iconNode = LayoutNode(config: { node in
            node.width = 24
            node.height = 24
        }) { (imageView: UIImageView, _) in
            imageView.contentMode = .scaleAspectFit
            imageView.yy_setImage(with: model.iconURL, options: .setImageWithFadeAnimation)
        }

        let nameNode = LayoutNode(sizeProvider: nameString, config: { node in
            node.marginLeft = 16
            node.flex = 1
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let topNode = LayoutNode(children: [iconNode, nameNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
        })

        let contentNode = LayoutNode(children: [topNode], config: { node in
            node.flexDirection = .column
            node.padding(all: 16)
        })

        return contentNode
    }
}
