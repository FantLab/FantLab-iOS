import Foundation
import UIKit
import ALLKit
import YYWebImage
import FLModels
import FLKit
import FLStyle

public final class AwardIconsLayoutSpec: ModelLayoutSpec<[AwardPreviewModel]> {
    public override func makeNodeFrom(model: [AwardPreviewModel], sizeConstraints: SizeConstraints) -> LayoutNode {
        var iconNodes: [LayoutNode] = []

        model.forEach { award in
            let iconNode = LayoutNode(config: { node in
                node.width = 24
                node.height = 24
                node.marginRight = 12
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
            node.padding(top: 6, left: 16, bottom: 8, right: nil)
        })

        return iconsNode
    }
}
