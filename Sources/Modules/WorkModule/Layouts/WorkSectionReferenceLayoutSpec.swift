import Foundation
import UIKit
import ALLKit
import yoga
import FantLabUtils
import FantLabStyle
import FantLabSharedUI

struct WorkSectionReferenceLayoutModel {
    let title: String
    let count: Int
}

final class WorkSectionReferenceLayoutSpec: ModelLayoutSpec<WorkSectionReferenceLayoutModel> {
    override func makeNodeFrom(model: WorkSectionReferenceLayoutModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let titleString = model.title.attributed()
            .font(AppStyle.iowanFonts.regularFont(ofSize: 17))
            .foregroundColor(AppStyle.colors.mainTextColor)
            .make()

        let countString = String(model.count).attributed()
            .font(AppStyle.systemFonts.regularFont(ofSize: 15))
            .foregroundColor(AppStyle.colors.secondaryTextColor)
            .make()

        let titleNode = LayoutNode(sizeProvider: titleString, config: { node in
            node.flex = 1
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = titleString
        }

        let countNode = LayoutNode(sizeProvider: countString, config: { node in
            node.marginLeft = 12
            node.isHidden = model.count < 1
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = countString
        }

        let contentNode = LayoutNode(children: [titleNode, countNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.justifyContent = .spaceBetween
        })

        return RightArrowLayoutSpec(model: contentNode).makeNodeWith(sizeConstraints: sizeConstraints)
    }
}
