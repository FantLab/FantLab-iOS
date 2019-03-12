import Foundation
import UIKit
import ALLKit
import FLStyle
import FLText
import FLKit
import FLModels
import YYWebImage

public final class WorkReviewWorkHeaderLayoutSpec: ModelLayoutSpec<WorkReviewModel> {
    public override func makeNodeFrom(model: WorkReviewModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString: NSAttributedString
        let infoString: NSAttributedString?
        let authorString: NSAttributedString?
        let markString: NSAttributedString?

        do {
            nameString = model.work.name.attributed()
                .font(Fonts.system.bold(size: 15))
                .foregroundColor(UIColor.black)
                .make()

            let yearText = model.work.year > 0 ? String(model.work.year) : ""
            let infoText = [model.work.type, yearText].compactAndJoin(", ")

            infoString = infoText.capitalizedFirstLetter().attributed()
                .font(Fonts.system.regular(size: 12))
                .foregroundColor(UIColor.gray)
                .make()

            authorString = model.work.authors.compactAndJoin(", ").nilIfEmpty?.attributed()
                .font(Fonts.system.medium(size: 12))
                .foregroundColor(Colors.fantasticBlue)
                .make()

            if model.mark > 0 {
                let markColor = RatingColorRule.colorFor(rating: Float(model.mark))

                if model.votes > 0 {
                    markString =
                        String(model.mark).attributed()
                            .font(Fonts.system.bold(size: 15))
                            .foregroundColor(markColor)
                            .make()
                        +
                        " +\(model.votes)".attributed()
                            .font(Fonts.system.regular(size: 11))
                            .foregroundColor(UIColor.lightGray)
                            .baselineOffset(4)
                            .make()
                } else {
                    markString = String(model.mark).attributed()
                        .font(Fonts.system.bold(size: 15))
                        .foregroundColor(markColor)
                        .make()
                }
            } else {
                markString = nil
            }
        }

        let nameNode = LayoutNode(sizeProvider: nameString, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let infoNode = LayoutNode(sizeProvider: infoString, config: { node in
            node.marginTop = 6
            node.isHidden = infoString == nil
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = infoString
        }

        let authorNode = LayoutNode(sizeProvider: authorString, config: { node in
            node.marginTop = 12
            node.isHidden = authorString == nil
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = authorString
        }

        let textStackNode = LayoutNode(children: [nameNode, infoNode, authorNode], config: { node in
            node.marginLeft = 16
            node.marginRight = 12
            node.flexDirection = .column
            node.flex = 1
            node.marginBottom = 8
        })

        let coverNode = LayoutNode(config: { node in
            node.height = 80
            node.width = 60
            node.alignSelf = .flexStart
        }) { (view: UIImageView, _) in
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFit
            view.image = WorkCoverImageRule.coverFor(workTypeId: model.work.typeId)
        }

        let markNode = LayoutNode(sizeProvider: markString, config: { node in
            node.marginLeft = 12
            node.isHidden = markString == nil
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = markString
        }

        let contentNode = LayoutNode(children: [coverNode, textStackNode, markNode], config: { node in
            node.alignItems = .center
            node.flexDirection = .row
            node.padding(top: 16, left: 16, bottom: nil, right: 16)
        })

        return contentNode
    }
}
