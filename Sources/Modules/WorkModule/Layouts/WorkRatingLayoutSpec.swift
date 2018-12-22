import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabUtils
import FantLabStyle

final class WorkRatingLayoutSpec: ModelLayoutSpec<WorkModel> {
    override func makeNodeFrom(model: WorkModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let ratingColor = RatingColorRule.colorFor(rating: model.rating)

        let intRating = min(10, max(0, Int(model.rating.rounded(.toNearestOrEven))))
        let starText = String(repeating: "★", count: intRating) + String(repeating: "☆", count: (10 - intRating))

        let ratingString = String(model.rating).attributed()
            .font(Fonts.system.bold(size: 18))
            .foregroundColor(ratingColor)
            .make()

        let starString = starText.attributed()
            .font(Fonts.system.regular(size: 13))
            .foregroundColor(UIColor(rgb: 0xFD8949))
            .make()

        let marksString = RussianPluralRule.format(value: model.votes, format: .marks, separator: " ").attributed()
            .font(Fonts.system.regular(size: 11))
            .foregroundColor(UIColor.lightGray)
            .make()

        let ratingNode = LayoutNode(sizeProvider: ratingString, config: nil) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = ratingString
        }

        let starNode = LayoutNode(sizeProvider: starString, config: { node in
            node.marginLeft = 8
            node.marginTop = 3
            node.flex = 1
        }) { (label: UILabel) in
            label.attributedText = starString
        }

        let marksNode = LayoutNode(sizeProvider: marksString, config: nil) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = marksString
        }

        let marksContainerNode = LayoutNode(children: [marksNode], config: { node in
            node.width = 100
            node.alignItems = .center
            node.justifyContent = .center
        })

        let contentNode = LayoutNode(children: [ratingNode, starNode, marksContainerNode], config: { node in
            node.paddingLeft = 24
            node.paddingRight = 24
            node.padding(top: nil, left: 16, bottom: 16, right: 16)
            node.flexDirection = .row
            node.alignItems = .center
        })

        return contentNode
    }
}
