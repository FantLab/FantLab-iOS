import Foundation
import UIKit
import ALLKit
import FantLabStyle
import FantLabText
import FantLabUtils
import FantLabModels
import YYWebImage

final class WorkReviewLayoutSpec: ModelLayoutSpec<WorkReviewModel> {
    override func makeNodeFrom(model: WorkReviewModel) -> LayoutNode {
        let userNameString = model.user.name.attributed()
            .font(AppStyle.shared.fonts.boldFont(ofSize: 15))
            .foregroundColor(AppStyle.shared.colors.mainTintColor)
            .make()

        let dateString = model.date?.formatDayMonthAndYearIfNotCurrent().attributed()
            .font(AppStyle.shared.fonts.regularFont(ofSize: 10))
            .foregroundColor(AppStyle.shared.colors.textSecondaryColor)
            .make()

        let markString = "Оценка: \(model.mark)".attributed()
            .font(AppStyle.shared.fonts.boldFont(ofSize: 13))
            .foregroundColor(AppStyle.shared.colors.textMainColor)
            .make()

        let showMark = model.mark > 0 && model.votes > 0

        let userAvatarNode = LayoutNode(children: [], config: { node in
            node.width = 32
            node.height = 32
            node.marginRight = 12
        }) { (view: UIImageView, isNew) in
            if isNew {
                view.layer.cornerRadius = 4
                view.layer.masksToBounds = true
                view.contentMode = .scaleAspectFill
            }

            view.yy_setImage(with: model.user.avatar, options: .setImageWithFadeAnimation)
        }

        let userNameNode = LayoutNode(sizeProvider: userNameString, config: { node in
            node.marginBottom = 4
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
            node.isHidden = !showMark
        }) { (label: UILabel, _) in
            label.attributedText = markString
            label.isHidden = !showMark
        }

        let topStackNode = LayoutNode(children: [userAvatarNode, userStackNode, markNode], config: { node in
            node.alignItems = .center
            node.flexDirection = .row
        })

        let text = FLAttributedText(taggedString: model.text, decorator: PreviewTextDecorator(), replacementRules: TagReplacementRules.previewAttachments)

        let textNode = LayoutNode(sizeProvider: text.string, config: { node in
            node.marginTop = 12
            node.maxHeight = 200
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = text.string
        }

        let backgroundNode = LayoutNode(children: [topStackNode, textNode], config: { node in
            node.flexDirection = .column
            node.padding(all: 16)
        }) { (view: UIView, isNew) in
            if isNew {
                view.backgroundColor = AppStyle.shared.colors.viewBackgroundColor
                view.layer.cornerRadius = 8
                view.layer.shouldRasterize = true
                view.layer.rasterizationScale = UIScreen.main.scale
                view.layer.shadowOpacity = 1
                view.layer.shadowColor = AppStyle.shared.colors.viewShadowColor.cgColor
                view.layer.shadowOffset = CGSize(width: 0, height: 4)
                view.layer.shadowRadius = 16
            }
        }

        let mainStack = LayoutNode(children: [backgroundNode], config: { node in
            node.padding(top: nil, left: 16, bottom: 16, right: 16)
            node.flexDirection = .column
        })

        return mainStack
    }
}
