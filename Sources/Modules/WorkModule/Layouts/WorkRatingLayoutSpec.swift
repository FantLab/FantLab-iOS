import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabUtils
import FantLabStyle

final class WorkRatingLayoutSpec: ModelLayoutSpec<WorkModel> {
    override func makeNodeFrom(model: WorkModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let ratingColor = RatingColorRule.colorFor(rating: model.rating)

        let ratingString = String(model.rating).attributed()
            .font(Fonts.system.bold(size: 24))
            .foregroundColor(ratingColor)
            .alignment(.center)
            .make()

        let votesString = RussianPluralRule.format(value: model.votes, format: .votes, separator: " ").attributed()
            .font(Fonts.system.regular(size: 11))
            .foregroundColor(UIColor.lightGray)
            .make()

        let ratingNode = LayoutNode(sizeProvider: ratingString, config: { node in
            node.width = 100
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = ratingString
        }

        let votesNode = LayoutNode(sizeProvider: votesString, config: nil) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = votesString
        }

        let contentNode = LayoutNode(children: [ratingNode, votesNode], config: { node in
            node.paddingLeft = 16
            node.paddingRight = 32
            node.flexDirection = .row
            node.alignItems = .flexEnd
            node.justifyContent = .spaceBetween
        })

        return contentNode
    }
}
