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

        let imageNode = LayoutNode(config: { node in
            node.width = 100
            node.height = 100
            node.marginBottom = 24
        }) { (view: UIImageView, _) in
            view.image = UIImage(named: "error")
            view.contentMode = .scaleAspectFit
        }

        let retryNode: LayoutNode?

        if model.1 {
            retryNode = LayoutNode(config: { node in
                node.width = 20
                node.height = 20
                node.marginTop = 24
                node.marginLeft = 8
            }) { (imageView: UIImageView, _) in
                imageView.tintColor = UIColor.lightGray
                imageView.contentMode = .scaleAspectFit
                imageView.image = UIImage(named: "reload")?.withRenderingMode(.alwaysTemplate)
            }
        } else {
            retryNode = nil
        }

        let contentNode = LayoutNode(children: [imageNode, textNode, retryNode], config: { node in
            node.padding(top: 32, left: 16, bottom: 32, right: 16)
            node.flexDirection = .column
            node.alignItems = .center
        })

        return contentNode
    }
}
