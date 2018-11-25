import Foundation
import UIKit
import ALLKit
import FantLabUtils
import FantLabStyle
import FantLabModels

final class WorkRatingLayoutSpec: ModelLayoutSpec<WorkModel> {
    override func makeNodeFrom(model: WorkModel) -> LayoutNode {
        let hasRating = model.rating > 0 && model.votes > 0

        let ratingString = (hasRating ? String(model.rating) : "N/A").attributed()
            .font(AppStyle.shared.fonts.boldFont(ofSize: 20))
            .foregroundColor(AppStyle.shared.colors.textMainColor)
            .make()

        let votesString = String(model.votes).attributed()
            .font(AppStyle.shared.fonts.regularFont(ofSize: 10))
            .foregroundColor(AppStyle.shared.colors.textSecondaryColor)
            .make()

        let reviewsString = "Отзывы (\(model.reviewsCount))".attributed()
            .font(AppStyle.shared.fonts.regularFont(ofSize: 14))
            .foregroundColor(AppStyle.shared.colors.textSecondaryColor)
            .make()

        let ratingNode = LayoutNode(sizeProvider: ratingString, config: nil) { (label: UILabel, _) in
            label.attributedText = ratingString
        }

        let votesNode = LayoutNode(sizeProvider: votesString, config: { node in
            node.isHidden = !hasRating
        }) { (label: UILabel, _) in
            label.attributedText = votesString
        }

        let leftStackNode = LayoutNode(children: [ratingNode, votesNode], config: { node in
            node.width = 80
            node.flexDirection = .column
            node.alignItems = .center
        })

        let reviewsNode = LayoutNode(sizeProvider: reviewsString, config: nil) { (label: UILabel, _) in
            label.attributedText = reviewsString
        }

        let mainNode = LayoutNode(children: [leftStackNode, reviewsNode], config: { node in
            node.flexDirection = .row
            node.padding(top: 8, left: 16, bottom: 8, right: 0)
            node.alignItems = .center
            node.justifyContent = .spaceBetween
        })

        return mainNode
    }
}
