import Foundation
import UIKit
import ALLKit
import FLStyle
import FLText
import FLKit
import FLModels

public final class WorkReviewUserHeaderLayoutSpec: ModelLayoutSpec<WorkReviewModel> {
    public override func makeNodeFrom(model: WorkReviewModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let userNameString = model.user.name.attributed()
            .font(Fonts.system.medium(size: 14))
            .foregroundColor(Colors.fantasticBlue)
            .make()

        let dateString = model.date?.formatToHumanReadbleText().attributed()
            .font(Fonts.system.regular(size: 11))
            .foregroundColor(UIColor.lightGray)
            .make()
        
        let userAvatarNode = LayoutNode(config: { node in
            node.width = 32
            node.height = 32
            node.marginRight = 12
        }) { (view: UIImageView, _) in
            view.layer.cornerRadius = 4
            view.layer.masksToBounds = true
            view.contentMode = .scaleAspectFill
            view.backgroundColor = Colors.perfectGray

            WebImage.load(url: model.user.avatar, into: view)
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
        
        let markStackNode: LayoutNode?
        
        if model.mark > 0 {
            markStackNode = WorkReviewRatingLayoutSpec(model: (model.mark, model.votes)).makeNodeWith(sizeConstraints: sizeConstraints)
        } else {
            markStackNode = nil
        }

        let contentNode = LayoutNode(children: [userAvatarNode, userStackNode, markStackNode], config: { node in
            node.alignItems = .center
            node.flexDirection = .row
            node.padding(top: 16, left: 16, bottom: nil, right: 16)
        })

        return contentNode
    }
}
