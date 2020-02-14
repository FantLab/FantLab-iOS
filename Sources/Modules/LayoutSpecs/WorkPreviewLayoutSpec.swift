import Foundation
import UIKit
import ALLKit
import yoga
import FLModels
import FLKit
import FLStyle

public final class WorkPreviewLayoutSpec: ModelLayoutSpec<WorkPreviewModel> {
    public override func makeNodeWith(boundingDimensions: LayoutDimensions<CGFloat>) -> LayoutNodeConvertible {
        let nameString: NSAttributedString
        let infoString: NSAttributedString?
        let authorString: NSAttributedString?
        let detailString: NSAttributedString?
        
        do {
            nameString = model.name.attributed()
                .font(Fonts.system.medium(size: 15))
                .foregroundColor(UIColor.black)
                .make()

            let yearText = model.year > 0 ? String(model.year) : ""
            let infoText = [model.type, yearText].compactAndJoin(", ")

            infoString = infoText.capitalizedFirstLetter().attributed()
                .font(Fonts.system.regular(size: 12))
                .foregroundColor(UIColor.gray)
                .make()

            authorString = model.authors.compactAndJoin(", ").nilIfEmpty?.attributed()
                .font(Fonts.system.medium(size: 12))
                .foregroundColor(Colors.fantasticBlue)
                .make()

            if model.rating > 0 && model.votes > 0 {
                let ratingColor = RatingColorRule.colorFor(rating: model.rating)

                detailString =
                    String(model.rating).attributed()
                        .font(Fonts.system.medium(size: 13))
                        .foregroundColor(ratingColor)
                        .alignment(.center)
                        .make()
                    +
                    ("\n" + String(model.votes)).attributed()
                        .font(Fonts.system.regular(size: 10))
                        .foregroundColor(UIColor.lightGray)
                        .alignment(.center)
                        .baselineOffset(-2)
                        .make()
            } else {
                detailString = nil
            }
        }

        let nameNode = LayoutNode(sizeProvider: nameString, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let infoNode = LayoutNode(sizeProvider: infoString, {
            node.marginTop = 6
            node.isHidden = infoString == nil
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = infoString
        }

        let authorNode = LayoutNode(sizeProvider: authorString, {
            node.marginTop = 12
            node.isHidden = authorString == nil
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = authorString
        }

        let textStackNode = LayoutNode(children: [nameNode, infoNode, authorNode], {
            node.marginLeft = 16
            node.marginRight = 12
            node.flexDirection = .column
            node.flex = 1
            node.marginBottom = 8
        })

        let coverNode = LayoutNode({
            node.height = 80
            node.width = 60
            node.alignSelf = .flexStart
        }) { (view: UIImageView, _) in
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFit
            view.image = WorkCoverImageRule.coverFor(workTypeId: model.typeId)
        }

        let detailTextNode = LayoutNode(sizeProvider: detailString, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = detailString
        }

        let detailContainerNode = LayoutNode(children: [detailTextNode], {
            node.alignItems = .center
            node.flexDirection = .column
            node.width = 48
            node.isHidden = detailString == nil
        })

        let arrowNode = LayoutNode({
            node.width = 10
            node.height = 10
        }) { (view: UIImageView, _) in
            view.contentMode = .scaleAspectFit
            view.tintColor = UIColor.lightGray
            view.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
            view.isHidden = model.id < 1
        }

        let contentNode = LayoutNode(children: [coverNode, textStackNode, detailContainerNode, arrowNode], {
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: 12, left: 16, bottom: 12, right: 12)
        })

        return contentNode
    }
}
