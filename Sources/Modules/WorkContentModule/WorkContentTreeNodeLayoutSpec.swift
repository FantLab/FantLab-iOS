import Foundation
import UIKit
import ALLKit
import yoga
import FantLabModels
import FantLabStyle
import FantLabUtils
import FantLabSharedUI

final class WorkContentTreeNodeLayoutSpec: ModelLayoutSpec<WorkContentTreeNode> {
    override func makeNodeFrom(model: WorkContentTreeNode, sizeConstraints: SizeConstraints) -> LayoutNode {
        guard let work = model.model else {
            return LayoutNode()
        }

        let titleString: NSAttributedString?

        do {
            let nameText = [work.name, work.origName].compactAndJoin(" / ")
            let plusText = work.plus ? "+" : ""
            let titleText = [plusText, nameText].compactAndJoin(" ")

            titleString = titleText.nilIfEmpty?.attributed()
                .font(work.isPublished ? AppStyle.iowanFonts.boldFont(ofSize: 15) : AppStyle.iowanFonts.regularFont(ofSize: 15))
                .foregroundColor(AppStyle.colors.mainTextColor)
                .make()
        }

        let subtitleString: NSAttributedString?

        do {
            let yearText = work.year > 0 ? String(work.year) : ""
            let nameText = (work.nameBonus.nilIfEmpty ?? work.workType).capitalizedFirstLetter()
            let subtitleText = ([nameText, yearText, work.publishStatus]).compactAndJoin(", ")

            subtitleString = subtitleText.nilIfEmpty?.attributed()
                .font(AppStyle.systemFonts.regularFont(ofSize: 13))
                .foregroundColor(AppStyle.colors.secondaryTextColor)
                .make()
        }

        let detailString: NSAttributedString?

        do {
            let detailText: String

            if !model.isExpanded && model.count > 0 {
                detailText = String(model.count)
            } else if work.rating > 0 && work.votes > 0 {
                detailText = "\(work.rating) (\(work.votes))"
            } else {
                detailText = ""
            }

            detailString = detailText.nilIfEmpty?.attributed()
                .font(AppStyle.systemFonts.regularFont(ofSize: 13))
                .foregroundColor(AppStyle.colors.secondaryTextColor)
                .make()
        }

        let detailIcon: UIImage?

        if !model.isExpanded && model.count > 0 {
            detailIcon = UIImage(named: "arrow_right")?.with(orientation: .right)
        } else if work.id > 0 {
            detailIcon = UIImage(named: "arrow_right")
        } else {
            detailIcon = nil
        }

        let titleNode = LayoutNode(sizeProvider: titleString, config: { node in
            node.isHidden = titleString == nil
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = titleString
        }

        let subtitleNode = LayoutNode(sizeProvider: subtitleString, config: { node in
            node.isHidden = subtitleString == nil
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = subtitleString
        }

        let detailNode = LayoutNode(sizeProvider: detailString, config: { node in
            node.marginLeft = 16
            node.isHidden = detailString == nil
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = detailString
        }

        let leftStackNode = LayoutNode(children: [titleNode, subtitleNode], config: { node in
            node.flex = 1
            node.flexDirection = .column
            node.alignItems = .flexStart
        })

        let textContentStackNode = LayoutNode(children: [leftStackNode, detailNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.justifyContent = .spaceBetween
            node.flex = 1
        })

        let iconNode = LayoutNode(config: { node in
            node.marginLeft = 8
            node.marginRight = 4
            node.width = 10
            node.height = 10
            node.isHidden = detailIcon == nil
        }) { (view: UIImageView) in
            view.contentMode = .scaleAspectFit
            view.tintColor = AppStyle.colors.arrowColor
            view.image = detailIcon?.withRenderingMode(.alwaysTemplate)
            view.isHidden = detailIcon == nil
        }

        let contentStackNode = LayoutNode(children: [textContentStackNode, iconNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: 12, left: YGValue(CGFloat(work.deepLevel * 16)), bottom: 12, right: 8)
        })

        let separatorNode = ItemSeparatorLayoutSpec().makeNodeWith(sizeConstraints: sizeConstraints)

        let mainStackNode = LayoutNode(children: [contentStackNode, separatorNode], config: { node in
            node.flexDirection = .column
        })

        return mainStackNode
    }
}
