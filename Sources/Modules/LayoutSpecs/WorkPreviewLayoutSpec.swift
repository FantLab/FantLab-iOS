import Foundation
import UIKit
import ALLKit
import yoga
import FantLabModels
import FantLabUtils
import FantLabStyle

public final class WorkPreviewLayoutSpec: ModelLayoutSpec<WorkPreviewModel> {
    public override func makeNodeFrom(model: WorkPreviewModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString: NSAttributedString
        let infoString: NSAttributedString?
        let authorString: NSAttributedString?
        let detailString: NSAttributedString?
        
        do {
            nameString = (model.name.nilIfEmpty ?? model.nameOrig).attributed()
                .font(Fonts.system.medium(size: 15))
                .foregroundColor(UIColor.black)
                .make()

            let yearText = model.year > 0 ? String(model.year) : ""
            let infoText = [model.workType, yearText].compactAndJoin(", ")

            infoString = infoText.capitalizedFirstLetter().attributed()
                .font(Fonts.system.regular(size: 12))
                .foregroundColor(UIColor.lightGray)
                .make()

            authorString = model.authors.compactAndJoin(", ").nilIfEmpty?.attributed()
                .font(Fonts.system.medium(size: 12))
                .foregroundColor(Colors.flBlue)
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

        let infoNode = LayoutNode(sizeProvider: infoString, config: { node in
            node.marginTop = 4
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

            view.yy_setImage(with: model.imageURL, placeholder: WorkCoverImageRule.coverFor(workType: model.workTypeKey), options: .setImageWithFadeAnimation, completion: nil)
        }

        let detailTextNode = LayoutNode(sizeProvider: detailString, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = detailString
        }

        let detailContainerNode = LayoutNode(children: [detailTextNode], config: { node in
            node.alignItems = .center
            node.flexDirection = .column
            node.width = 48
            node.isHidden = detailString == nil
        })

        let arrowNode = LayoutNode(config: { node in
            node.width = 10
            node.height = 10
        }) { (view: UIImageView, _) in
            view.contentMode = .scaleAspectFit
            view.tintColor = UIColor.lightGray
            view.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
            view.isHidden = model.id < 1
        }

        let contentNode = LayoutNode(children: [coverNode, textStackNode, detailContainerNode, arrowNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: 12, left: 16, bottom: 12, right: 12)
        })

        return contentNode
    }
}
