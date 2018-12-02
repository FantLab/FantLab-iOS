import Foundation
import UIKit
import ALLKit
import FantLabUtils
import FantLabStyle
import FantLabModels
import FantLabSharedUI

final class WorkRatingLayoutSpec: ModelLayoutSpec<WorkModel> {
    override func makeNodeFrom(model: WorkModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let ratingString = String(model.rating).attributed()
            .font(AppStyle.systemFonts.boldFont(ofSize: 24))
            .foregroundColor(AppStyle.colors.secondaryTintColor)
            .make()

        let votesString = RussianPluralRule.format(value: model.votes, .votes).attributed()
            .font(AppStyle.systemFonts.regularFont(ofSize: 12))
            .foregroundColor(AppStyle.colors.secondaryTextColor)
            .make()

        let ratingNode = LayoutNode(sizeProvider: ratingString, config: nil) { (label: UILabel) in
            label.attributedText = ratingString
        }

        let votesNode = LayoutNode(sizeProvider: votesString, config: nil) { (label: UILabel) in
            label.attributedText = votesString
        }

        let contentNode = LayoutNode(children: [ratingNode, votesNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.justifyContent = .spaceBetween
            node.padding(top: nil, left: 16, bottom: 12, right: 16)
        })

        return contentNode
    }
}
