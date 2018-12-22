import Foundation
import UIKit
import ALLKit
import FantLabStyle
import FantLabText
import FantLabUtils
import FantLabModels
import FantLabSharedUI
import YYWebImage

final class WorkReviewHeaderLayoutSpec: ModelLayoutSpec<WorkReviewModel> {
    override func makeNodeFrom(model: WorkReviewModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let userNameString = model.user.name.attributed()
            .font(Fonts.system.medium(size: 14))
            .foregroundColor(Colors.flBlue)
            .make()

        let dateString = model.date?.formatDayMonthAndYearIfNotCurrent().attributed()
            .font(Fonts.system.regular(size: 11))
            .foregroundColor(UIColor.lightGray)
            .make()

        let markString: NSAttributedString?

        if model.mark > 0 && model.votes > 0 {
            let mark = "Оценка: \(model.mark)".attributed()
                .font(Fonts.system.bold(size: 12))
                .foregroundColor(UIColor.black)
                .makeMutable()

            //            let votes = (" (" + String(model.votes) + ")").attributed()
            //                .font(Fonts.system.regular(size: 10))
            //                .foregroundColor(UIColor.lightGray)
            //                .baselineOffset(1)
            //                .make()
            //
            //            mark.append(votes)

            markString = mark
        } else {
            markString = nil
        }

        let userAvatarNode = LayoutNode(config: { node in
            node.width = 32
            node.height = 32
            node.marginRight = 12
        }) { (view: UIImageView) in
            view.layer.cornerRadius = 4
            view.layer.masksToBounds = true
            view.contentMode = .scaleAspectFill
            view.yy_setImage(with: model.user.avatar, options: .setImageWithFadeAnimation)
        }

        let userNameNode = LayoutNode(sizeProvider: userNameString, config: { node in
            node.marginBottom = 2
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = userNameString
        }

        let dateNode = LayoutNode(sizeProvider: dateString, config: nil) { (label: UILabel) in
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
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = markString
        }

        let contentNode = LayoutNode(children: [userAvatarNode, userStackNode, markNode], config: { node in
            node.alignItems = .center
            node.flexDirection = .row
            node.padding(top: 16, left: 24, bottom: 16, right: 24)
        })

        return contentNode
    }
}

final class WorkReviewTextLayoutSpec: ModelLayoutSpec<WorkReviewModel> {
    override func makeNodeFrom(model: WorkReviewModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let text = FLAttributedText(taggedString: model.text, decorator: PreviewTextDecorator(), replacementRules: TagReplacementRules.previewAttachments)

        let textDrawing = text.string.drawing(options: [.truncatesLastVisibleLine, .usesFontLeading, .usesLineFragmentOrigin])

        let textNode = LayoutNode(sizeProvider: textDrawing, config: { node in
            node.maxHeight = 120
        }) { (label: AsyncLabel) in
            label.stringDrawing = textDrawing
        }

        let contentNode = LayoutNode(children: [textNode], config: { node in
            node.padding(top: 8, left: 24, bottom: 16, right: 24)
        })

        return contentNode
    }
}
