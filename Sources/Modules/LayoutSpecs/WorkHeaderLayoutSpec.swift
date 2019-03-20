import Foundation
import UIKit
import ALLKit
import YYWebImage
import FLKit
import FLStyle
import FLModels

public final class WorkHeaderLayoutSpec: ModelLayoutSpec<(WorkModel, () -> Void)> {
    public override func makeNodeFrom(model: (WorkModel, () -> Void), sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString: NSAttributedString
        let origNameString: NSAttributedString?
        let infoString: NSAttributedString
        let authorString: NSAttributedString?

        do {
            let nameText = model.0.name.nilIfEmpty ?? model.0.origName

            nameString = nameText.attributed()
                .font(Fonts.system.bold(size: TitleFontSizeRule.fontSizeFor(length: nameText.count)))
                .foregroundColor(UIColor.black)
                .hyphenationFactor(1)
                .make()

            if !model.0.origName.isEmpty && model.0.origName != nameText {
                origNameString = model.0.origName.attributed()
                    .font(Fonts.system.medium(size: 12))
                    .foregroundColor(UIColor.lightGray)
                    .make()
            } else {
                origNameString = nil
            }

            let yearText = model.0.year > 0 ? String(model.0.year) : ""
            let infoText = ([model.0.workType, yearText] + model.0.publishStatuses).compactAndJoin(", ")

            infoString = infoText.attributed()
                .font(Fonts.system.regular(size: 14))
                .foregroundColor(UIColor.gray)
                .make()

            let authors = model.0.authors.map { $0.name }.compactAndJoin(", ")

            if !authors.isEmpty {
                authorString = authors.attributed()
                    .font(Fonts.system.medium(size: 15))
                    .foregroundColor(Colors.fantasticBlue)
                    .make()
            } else {
                authorString = nil
            }
        }

        let coverNode = LayoutNode(config: { node in
            node.width = 100
            node.height = 120
            node.marginLeft = 16
        }) { (view: UIImageView, _) in
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFit
            view.image = WorkCoverImageRule.coverFor(workType: model.0.workTypeKey)
        }

        let nameNode = LayoutNode(sizeProvider: nameString, config: { node in

        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let origNameNode = LayoutNode(sizeProvider: origNameString, config: { node in
            node.marginTop = 4
            node.isHidden = origNameString == nil
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = origNameString
        }

        let infoNode = LayoutNode(sizeProvider: infoString, config: { node in
            node.marginTop = 8
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = infoString
        }

        let authorNode = LayoutNode(sizeProvider: authorString, config: { node in
            node.marginTop = 16
            node.isHidden = authorString == nil
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = authorString
            label.isUserInteractionEnabled = true
            label.all_addGestureRecognizer({ [weak label] (_: UITapGestureRecognizer) in
                label?.animated(action: model.1, alpha: 0.3)
            })
        }

        let textStackNode = LayoutNode(children: [nameNode, origNameNode, infoNode, authorNode], config: { node in
            node.flexDirection = .column
            node.alignItems = .flexStart
            node.alignSelf = .center
            node.flex = 1
        })

        let contentNode = LayoutNode(children: [textStackNode, coverNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .flexStart
            node.padding(all: 16)
        })

        return contentNode
    }
}
