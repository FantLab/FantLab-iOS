import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabStyle

public final class AuthorWebSiteLayoutSpec: ModelLayoutSpec<AuthorModel.SiteModel> {
    public override func makeNodeFrom(model: AuthorModel.SiteModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString = model.title.capitalizedFirstLetter().attributed()
            .font(Fonts.system.regular(size: 15))
            .foregroundColor(Colors.flBlue)
            .make()

        let nameNode = LayoutNode(sizeProvider: nameString, config: { node in
            node.flex = 1
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let arrowNode = LayoutNode(config: { node in
            node.marginLeft = 8
            node.width = 10
            node.height = 10
        }) { (view: UIImageView, _) in
            view.contentMode = .scaleAspectFit
            view.tintColor = UIColor.lightGray
            view.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
        }

        let contentNode = LayoutNode(children: [nameNode, arrowNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: 16, left: 16, bottom: 16, right: 12)
        })

        return contentNode
    }
}
