import Foundation
import UIKit
import ALLKit
import YYWebImage
import FantLabUtils
import FantLabStyle
import FantLabModels

final class WorkHeaderLayoutSpec: ModelLayoutSpec<WorkModel> {
    override func makeNodeFrom(model: WorkModel) -> LayoutNode {
        let nameString: NSAttributedString?

        do {
            let name = [model.name, model.origName].compactAndJoin(" / ")

            nameString = name.nilIfEmpty?.attributed()
                .font(AppStyle.shared.fonts.boldFont(ofSize: 16))
                .foregroundColor(AppStyle.shared.colors.textMainColor)
                .make()
        }

        let authorString: NSAttributedString?

        do {
            let author = model.authors.map({ $0.name }).compactAndJoin(", ")

            authorString = author.nilIfEmpty?.attributed()
                .font(AppStyle.shared.fonts.boldFont(ofSize: 12))
                .foregroundColor(AppStyle.shared.colors.secondaryTextColor)
                .make()
        }

        let infoString: NSAttributedString?

        do {
            let yearString = model.year > 0 ? String(model.year) : ""
            let info = ([model.workType, yearString] + model.publishStatuses).compactAndJoin(", ")

            infoString = info.nilIfEmpty?.attributed()
                .font(AppStyle.shared.fonts.regularFont(ofSize: 14))
                .foregroundColor(AppStyle.shared.colors.textSecondaryColor)
                .make()
        }

        let nameNode = LayoutNode(sizeProvider: nameString, config: { node in
            node.isHidden = nameString == nil
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let authorNode = LayoutNode(sizeProvider: authorString, config: { node in
            node.marginTop = 6
            node.maxHeight = 40
            node.isHidden = authorString == nil
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = authorString
        }

        let infoNode = LayoutNode(sizeProvider: infoString, config: { node in
            node.marginTop = 6
            node.isHidden = infoString == nil
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = infoString
        }

        let textNode = LayoutNode(children: [nameNode, authorNode, infoNode], config: { node in
            node.flex = 1
            node.flexDirection = .column
        })

        let imageNode = LayoutNode(children: [], config: { node in
            node.width = 80
            node.aspectRatio = Float(3.0/4.0)
            node.marginRight = 16
        }) { (imageView: UIImageView, _) in
            imageView.layer.cornerRadius = 2
            imageView.layer.masksToBounds = true
            imageView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) // TODO:
            imageView.contentMode = .scaleToFill
            imageView.yy_setImage(with: model.imageURL, options: .setImageWithFadeAnimation)
        }

        let mainNode = LayoutNode(children: [imageNode, textNode], config: { node in
            node.flexDirection = .row
            node.padding(all: 16)
            node.alignItems = .flexStart
        })

        return mainNode
    }
}
