import Foundation
import UIKit
import ALLKit
import YYWebImage
import FantLabModels
import FantLabUtils
import FantLabStyle

public final class AwardIconsLayoutSpec: ModelLayoutSpec<[AwardPreviewModel]> {
    public override func makeNodeFrom(model: [AwardPreviewModel], sizeConstraints: SizeConstraints) -> LayoutNode {
        var iconNodes: [LayoutNode] = []

        model.forEach { award in
            let iconNode = LayoutNode(config: { node in
                node.width = 24
                node.height = 24
                node.marginRight = 16
                node.marginTop = 6
                node.marginBottom = 6
            }) { (imageView: UIImageView, _) in
                imageView.contentMode = .scaleAspectFit
                imageView.yy_setImage(with: award.iconURL, options: .setImageWithFadeAnimation)
            }

            iconNodes.append(iconNode)
        }

        let iconsNode = LayoutNode(children: iconNodes, config: { node in
            node.flexDirection = .row
            node.flexWrap = .wrap
            node.flex = 1
        })

        let arrowNode = LayoutNode(config: { node in
            node.width = 10
            node.height = 10
        }) { (view: UIImageView, _) in
            view.contentMode = .scaleAspectFit
            view.tintColor = UIColor.lightGray
            view.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
        }

        let contentNode = LayoutNode(children: [iconsNode, arrowNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: 6, left: 16, bottom: 6, right: 12)
        })

        return contentNode
    }
}
