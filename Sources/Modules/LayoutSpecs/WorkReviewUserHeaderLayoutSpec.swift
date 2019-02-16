import Foundation
import UIKit
import ALLKit
import FantLabStyle
import FantLabText
import FantLabUtils
import FantLabModels
import YYWebImage

public final class WorkReviewUserHeaderLayoutSpec: ModelLayoutSpec<WorkReviewModel> {
    public override func makeNodeFrom(model: WorkReviewModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let userNameString = model.user.name.attributed()
            .font(Fonts.system.medium(size: 14))
            .foregroundColor(Colors.flBlue)
            .make()

        let dateString = model.date?.formatToHumanReadbleText().attributed()
            .font(Fonts.system.regular(size: 11))
            .foregroundColor(UIColor.lightGray)
            .make()

        let markString: NSAttributedString?

        if model.mark > 0 {
            let markColor = RatingColorRule.colorFor(rating: Float(model.mark))

            if model.votes > 0 {
                markString =
                    String(model.mark).attributed()
                        .font(Fonts.system.bold(size: 15))
                        .foregroundColor(markColor)
                        .make()
                    +
                    " +\(model.votes)".attributed()
                        .font(Fonts.system.regular(size: 11))
                        .foregroundColor(UIColor.lightGray)
                        .baselineOffset(4)
                        .make()
            } else {
                markString = String(model.mark).attributed()
                    .font(Fonts.system.bold(size: 15))
                    .foregroundColor(markColor)
                    .make()
            }
        } else {
            markString = nil
        }

        let userAvatarNode = LayoutNode(config: { node in
            node.width = 32
            node.height = 32
            node.marginRight = 12
        }) { (view: UIImageView, _) in
            view.layer.cornerRadius = 4
            view.layer.masksToBounds = true
            view.contentMode = .scaleAspectFill
            view.backgroundColor = Colors.perfectGray
            view.yy_setImage(with: model.user.avatar, options: .setImageWithFadeAnimation)
        }

        let userNameNode = LayoutNode(sizeProvider: userNameString, config: { node in
            node.marginBottom = 2
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = userNameString
        }

        let dateNode = LayoutNode(sizeProvider: dateString, config: nil) { (label: UILabel, _) in
            label.attributedText = dateString
        }

        let userStackNode = LayoutNode(children: [userNameNode, dateNode], config: { node in
            node.flex = 1
            node.flexDirection = .column
            node.alignItems = .flexStart
        })

        let markNode = LayoutNode(sizeProvider: markString, config: { node in
            node.marginLeft = 12
            node.isHidden = markString == nil
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = markString
        }

        let contentNode = LayoutNode(children: [userAvatarNode, userStackNode, markNode], config: { node in
            node.alignItems = .center
            node.flexDirection = .row
            node.padding(top: 16, left: 16, bottom: nil, right: 16)
        })

        return contentNode
    }
}
