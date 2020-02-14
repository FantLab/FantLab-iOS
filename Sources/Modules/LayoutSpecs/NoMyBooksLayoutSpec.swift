import Foundation
import UIKit
import ALLKit
import FLKit
import FLStyle

public final class NoMyBooksLayoutSpec: LayoutSpec {
    public override func makeNodeWith(sizeConstraints: SizeConstraints) -> LayoutNode {
        let imageNode = LayoutNode({
            node.width = 200
            node.height = 136
            node.marginBottom = 48
        }) { (view: UIImageView, _) in
            view.image = UIImage(named: "bukah")
            view.contentMode = .scaleAspectFit
        }

        let contentNode = LayoutNode(children: [imageNode], {
            node.flexDirection = .column
            node.alignItems = .center
            node.justifyContent = .center
        })

        return contentNode
    }
}

