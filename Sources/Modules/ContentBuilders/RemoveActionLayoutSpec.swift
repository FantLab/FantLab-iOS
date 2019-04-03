import Foundation
import UIKit
import ALLKit
import yoga

public final class RemoveActionLayoutSpec: LayoutSpec {
    public override func makeNodeWith(sizeConstraints: SizeConstraints) -> LayoutNode {
        let icon = UIImage(named: "trash")
        let size = icon?.size ?? .zero
        
        let iconNode = LayoutNode(config: { node in
            node.width = YGValue(size.width)
            node.height = YGValue(size.height)
        }) { (view: UIImageView, _) in
            view.contentMode = .scaleAspectFill
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
