import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabStyle
import FantLabUtils

public final class AuthorPreviewLayoutSpec: ModelLayoutSpec<AuthorPreviewModel> {
    public override func makeNodeFrom(model: AuthorPreviewModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString = model.name.attributed()
            .font(Fonts.system.medium(size: 15))
            .foregroundColor(UIColor.black)
            .make()

        let imageNode = LayoutNode(config: { node in
            node.width = 60
            node.height = 60
            node.marginRight = 16
        }) { (view: UIImageView, _) in
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFill
            view.layer.cornerRadius = 30
            view.backgroundColor = Colors.perfectGray

            view.yy_setImage(with: model.photoURL, options: .setImageWithFadeAnimation)
        }

        let nameNode = LayoutNode(sizeProvider: nameString, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let spacingNode = LayoutNode(config: { node in
            node.flex = 1
        })

        let arrowNode = LayoutNode(config: { node in
            node.marginLeft = 8
            node.width = 10
            node.height = 10
        }) { (view: UIImageView, _) in
            view.contentMode = .scaleAspectFit
            view.tintColor = UIColor.lightGray
            view.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
        }

        let contentNode = LayoutNode(children: [imageNode, nameNode, spacingNode, arrowNode], config: { node in
            node.padding(top: 16, left: 16, bottom: 16, right: 12)
            node.flexDirection = .row
            node.alignItems = .center
        })

        return contentNode
    }
}
