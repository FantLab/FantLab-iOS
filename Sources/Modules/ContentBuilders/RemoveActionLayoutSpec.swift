import Foundation
import UIKit
import ALLKit

public final class RemoveActionLayoutSpec: LayoutSpec {
    public override func makeNodeWith(sizeConstraints: SizeConstraints) -> LayoutNode {
        let icon = UIImage(named: "trash")

        let iconNode = LayoutNode(sizeProvider: icon?.size) { (view: UIImageView, _) in
            view.image = icon?.withRenderingMode(.alwaysTemplate)
            view.tintColor = UIColor.white
        }

        let contentNode = LayoutNode(children: [iconNode], config: { node in
            node.alignItems = .center
            node.justifyContent = .center
        })

        return contentNode
    }
}
