import Foundation
import UIKit
import ALLKit
import yoga
import FantLabUtils
import FantLabStyle

public final class EmptySpaceLayoutSpec: ModelLayoutSpec<(UIColor, Int)> {
    public override func makeNodeFrom(model: (UIColor, Int), sizeConstraints: SizeConstraints) -> LayoutNode {
        return LayoutNode(config: { node in
            node.height = YGValue(CGFloat(model.1))
        }) { (view: UIView, _) in
            view.backgroundColor = model.0
        }
    }
}
