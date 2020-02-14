import Foundation
import UIKit
import ALLKit
import FLModels
import FLKit
import FLStyle

public final class AwardIconsLayoutSpec: ModelLayoutSpec<[AwardPreviewModel]> {
    public override func makeNodeFrom(model: [AwardPreviewModel], sizeConstraints: SizeConstraints) -> LayoutNode {
        var iconNodes: [LayoutNode] = []

        model.forEach { award in
            let iconNode = LayoutNode({
                node.width = 24
                node.height = 24
                node.margin(all: 8)
            }) { (imageView: UIImageView, _) in
                imageView.contentMode = .scaleAspectFit

                WebImage.load(url: award.iconURL, into: imageView)
            }

            iconNodes.append(iconNode)
        }

        let iconsNode = LayoutNode(children: iconNodes, {
            node.flexDirection = .row
            node.justifyContent = .flexStart
            node.flexWrap = .wrap
            node.padding(top: 6, left: 12, bottom: 12, right: 6)
        })

        return iconsNode
    }
}
