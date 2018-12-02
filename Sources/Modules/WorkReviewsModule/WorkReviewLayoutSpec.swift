import Foundation
import UIKit
import ALLKit
import FantLabStyle
import FantLabText
import FantLabUtils
import FantLabModels
import YYWebImage

final class WorkReviewLayoutSpec: ModelLayoutSpec<WorkReviewModel> {
    override func makeNodeFrom(model: WorkReviewModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let userNameString = model.user.name.attributed()
            .font(AppStyle.iowanFonts.boldFont(ofSize: 15))
            .foregroundColor(AppStyle.colors.mainTintColor)
            .make()

        let dateString = model.date?.formatDayMonthAndYearIfNotCurrent().attributed()
            .font(AppStyle.iowanFonts.regularFont(ofSize: 10))
            .foregroundColor(AppStyle.colors.secondaryTextColor)
            .make()

        let markString = "Оценка: \(model.mark)".attributed()
            .font(AppStyle.iowanFonts.boldFont(ofSize: 13))
            .foregroundColor(AppStyle.colors.mainTextColor)
            .make()

        let showMark = model.mark > 0 && model.votes > 0

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
            node.isHidden = !showMark
        }) { (label: UILabel) in
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
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = text.string
        }

        let backgroundNode = LayoutNode(children: [topStackNode, textNode], config: { node in
            node.flexDirection = .column
            node.padding(all: 16)
        }) { (view: UIView) in
            view.backgroundColor = AppStyle.colors.viewBackgroundColor
            view.layer.cornerRadius = 8
            view.layer.shouldRasterize = true
            view.layer.rasterizationScale = UIScreen.main.scale
            view.layer.shadowOpacity = 1
            view.layer.shadowColor = AppStyle.colors.viewShadowColor.cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 4)
            view.layer.shadowRadius = 16
        }

        let mainStack = LayoutNode(children: [backgroundNode], config: { node in
            node.padding(top: nil, left: 16, bottom: 16, right: 16)
            node.flexDirection = .column
        })

        return mainStack
    }
}
