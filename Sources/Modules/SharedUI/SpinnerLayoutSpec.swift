import Foundation
import UIKit
import ALLKit

public final class SpinnerLayoutSpec: LayoutSpec {
    public override func makeNodeWith(sizeConstraints: SizeConstraints) -> LayoutNode {
        let spinnerNode = LayoutNode(config: { node in
            node.width = 32
            node.height = 32
        }) { (view: UIActivityIndicatorView) in
            view.style = .gray
            view.startAnimating()
        }

        let containerNode = LayoutNode(children: [spinnerNode], config: { node in
            node.alignItems = .center
            node.justifyContent = .center
            node.height = 100
        })

        return containerNode
    }
}
