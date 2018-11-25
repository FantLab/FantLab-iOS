import Foundation
import UIKit
import ALLKit

public final class SpinnerLayoutSpec: LayoutSpec {
    public override func makeNode() -> LayoutNode {
        let spinnerNode = LayoutNode(children: [], config: { node in
            node.width = 32
            node.height = 32
        }) { (view: UIActivityIndicatorView, _) in
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
