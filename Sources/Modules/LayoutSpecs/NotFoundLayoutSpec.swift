import Foundation
import UIKit
import ALLKit
import FLKit
import FLStyle

public final class NotFoundLayoutSpec: ModelLayoutSpec<String> {
    public override func makeNodeFrom(model: String, sizeConstraints: SizeConstraints) -> LayoutNode {
        let string = "По запросу «\(model)» ничего не найдено".attributed()
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
            view.image = UIImage(named: "not_found")
            view.contentMode = .scaleAspectFit
        }

        let contentNode = LayoutNode(children: [imageNode, textNode], config: { node in
            node.padding(top: 32, left: 16, bottom: 32, right: 16)
            node.flexDirection = .column
            node.alignItems = .center
        })

        return contentNode
    }
}

