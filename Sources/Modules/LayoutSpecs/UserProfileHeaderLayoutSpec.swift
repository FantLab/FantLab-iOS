import Foundation
import UIKit
import ALLKit
import YYWebImage
import FLModels
import FLStyle
import FLKit

public final class UserProfileHeaderLayoutSpec: ModelLayoutSpec<UserProfileModel> {
    public override func makeNodeFrom(model: UserProfileModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let loginString = model.login.attributed()
            .font(Fonts.system.bold(size: TitleFontSizeRule.fontSizeFor(length: model.login.count)))
            .foregroundColor(UIColor.black)
            .alignment(.center)
            .make()

        let loginNode = LayoutNode(sizeProvider: loginString, config: { node in

        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = loginString
        }

        let userClassNode: LayoutNode?

        if !model.isBlocked && !model.userClass.isEmpty {
            let string = model.userClass.capitalizedFirstLetter().attributed()
                .font(Fonts.system.regular(size: 16))
                .foregroundColor(UIColor.gray)
                .make()

            userClassNode = LayoutNode(sizeProvider: string, config: { node in
                node.marginTop = 12
            }) { (label: UILabel, _) in
                label.numberOfLines = 0
                label.attributedText = string
            }
        } else {
            userClassNode = nil
        }

        let banImageNode: LayoutNode?

        if model.isBlocked {
            banImageNode = LayoutNode(config: { node in
                node.position = .absolute
                node.top = 0
                node.right = 0
                node.bottom = 0
                node.left = 0
            }) { (imageView: UIImageView, _) in
                imageView.tintColor = UIColor.red
                imageView.image = UIImage(named: "ban")?.withRenderingMode(.alwaysTemplate)
            }
        } else {
            banImageNode = nil
        }

        let imageNode = LayoutNode(children: [banImageNode], config: { node in
            node.width = 120
            node.height = 120
            node.marginBottom = 16
        }) { (imageView: UIImageView, _) in
            imageView.backgroundColor = Colors.perfectGray
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 60
            imageView.clipsToBounds = true
            imageView.yy_setImage(with: model.avatar, options: .setImageWithFadeAnimation)
        }

        let contentNode = LayoutNode(children: [imageNode, loginNode, userClassNode], config: { node in
            node.padding(all: 32)
            node.flexDirection = .column
            node.alignItems = .center
        })

        return contentNode
    }
}
