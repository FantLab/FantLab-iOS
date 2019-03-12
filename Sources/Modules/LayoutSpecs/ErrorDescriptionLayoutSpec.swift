import Foundation
import UIKit
import ALLKit
import FLKit
import FLStyle

public final class ErrorDescriptionLayoutSpec: ModelLayoutSpec<(String, Bool)> {
    public override func makeNodeFrom(model: (String, Bool), sizeConstraints: SizeConstraints) -> LayoutNode {
        let string = model.0.attributed()
            .font(Fonts.system.regular(size: 15))
            .foregroundColor(UIColor.lightGray)
            .alignment(.center)
            .make()

        let textNode = LayoutNode(sizeProvider: string, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = string
        }

        let retryNode: LayoutNode?

        if model.1 {
            retryNode = LayoutNode(config: { node in
                node.width = 20
                node.height = 20
                node.marginTop = 12
            }) { (imageView: UIImageView, _) in
                imageView.tintColor = UIColor.lightGray
                imageView.contentMode = .scaleAspectFit
                imageView.image = UIImage(named: "reload")?.withRenderingMode(.alwaysTemplate)
            }
        } else {
            retryNode = nil
        }

        let contentNode = LayoutNode(children: [textNode, retryNode], config: { node in
            node.padding(top: 64, left: 16, bottom: 64, right: 16)
            node.flexDirection = .column
            node.alignItems = .center
        })

        return contentNode
    }
}
