import Foundation
import UIKit
import ALLKit
import FLStyle
import FLText
import FLKit
import FLModels

public final class WorkReviewUserHeaderLayoutSpec: ModelLayoutSpec<WorkReviewModel> {
    public override func makeNodeWith(boundingDimensions: LayoutDimensions<CGFloat>) -> LayoutNodeConvertible {
        let userNameString = model.user.name.attributed()
            .font(Fonts.system.medium(size: 14))
            .foregroundColor(Colors.fantasticBlue)
            .make()

        let dateString = model.date?.formatToHumanReadbleText().attributed()
            .font(Fonts.system.regular(size: 11))
            .foregroundColor(UIColor.lightGray)
            .make()
        
        let userAvatarNode = LayoutNode({
            $0.width(32).height(32).margin(.right(12))
        }) { (view: UIImageView, _) in
            view.layer.cornerRadius = 4
            view.layer.masksToBounds = true
            view.contentMode = .scaleAspectFill
            view.backgroundColor = Colors.perfectGray

            WebImage.load(url: self.model.user.avatar, into: view)
        }

        let userNameNode = LayoutNode(sizeProvider: userNameString, {
            $0.margin(.bottom(2))
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = userNameString
        }

        let dateNode = LayoutNode(sizeProvider: dateString) { (label: UILabel, _) in
            label.attributedText = dateString
        }

        let userStackNode = LayoutNode(children: [userNameNode, dateNode], {
            $0.flex(1).flexDirection(.column).alignItems(.flexStart)
        })
        
        let markStackNode: LayoutNodeConvertible?
        
        if model.mark > 0 {
            markStackNode = WorkReviewRatingLayoutSpec(model: (model.mark, model.votes)).makeNodeWith(boundingDimensions: boundingDimensions)
        } else {
            markStackNode = nil
        }

        let contentNode = LayoutNode(children: [userAvatarNode, userStackNode, markStackNode], {
            $0.alignItems(.center).flexDirection(.row).padding(.horizontal(16), .top(16))
        })

        return contentNode
    }
}
