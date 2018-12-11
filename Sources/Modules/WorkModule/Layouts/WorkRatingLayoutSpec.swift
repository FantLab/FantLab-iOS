import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabUtils
import FantLabStyle

final class WorkRatingLayoutSpec: ModelLayoutSpec<WorkModel> {
    override func makeNodeFrom(model: WorkModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let ratingColor = RatingColorRule.colorFor(rating: model.rating)

        let intRating = min(10, max(0, Int(model.rating)))
        let starText = String(repeating: "★", count: intRating) + String(repeating: "☆", count: (10 - intRating))

        let ratingString = String(model.rating).attributed()
            .font(Fonts.system.bold(size: 28))
            .foregroundColor(ratingColor)
            .make()

        let starString = starText.attributed()
            .font(Fonts.system.regular(size: 13))
            .foregroundColor(UIColor.lightGray)
            .make()

        let votesString = RussianPluralRule.format(value: model.votes, format: .votes, separator: " ").attributed()
            .font(Fonts.system.regular(size: 11))
            .foregroundColor(UIColor.lightGray)
            .alignment(.right)
            .make()

        let ratingNode = LayoutNode(sizeProvider: ratingString, config: { node in

        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = ratingString
        }

        let starNode = LayoutNode(sizeProvider: starString, config: { node in
            node.marginLeft = 8
            node.marginTop = 6
        }) { (label: UILabel) in
            label.attributedText = starString
        }

        let votesNode = LayoutNode(sizeProvider: votesString, config: { node in
            node.marginLeft = 8
            node.marginTop = 6
            node.flex = 1
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = votesString
        }

        let contentNode = LayoutNode(children: [ratingNode, starNode, votesNode], config: { node in
            node.paddingLeft = 24
            node.paddingRight = 24
            node.flexDirection = .row
            node.alignItems = .center
        })

        return contentNode
    }
}
