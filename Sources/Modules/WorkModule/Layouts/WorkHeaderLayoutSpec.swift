import Foundation
import UIKit
import ALLKit
import YYWebImage
import FantLabUtils
import FantLabStyle
import FantLabModels

final class WorkHeaderLayoutSpec: ModelLayoutSpec<WorkModel> {
    override func makeNodeFrom(model: WorkModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString: NSAttributedString
        let authorString: NSAttributedString
        let infoString: NSAttributedString

        do {
            let nameText = model.name == model.origName ? model.name : [model.name, model.origName].compactAndJoin(" / ")

            nameString = nameText.attributed()
                .font(Fonts.iowan.bold(size: 20))
                .foregroundColor(UIColor.black)
                .make()

            authorString = model.authors.map({ $0.name }).compactAndJoin(", ").attributed()
                .font(Fonts.iowan.bold(size: 15))
                .foregroundColor(Colors.flBlue)
                .make()

            let yearText = model.year > 0 ? String(model.year) : ""
            let infoText = ([model.workType, yearText] + model.publishStatuses).compactAndJoin(", ")

            infoString = infoText.attributed()
                .font(Fonts.system.regular(size: 13))
                .foregroundColor(UIColor.lightGray)
                .make()
        }

        let coverNode = LayoutNode(config: { node in
            node.width = 100
            node.height = 150
        }) { (view: UIImageView) in
            view.contentMode = .scaleAspectFit

            view.yy_setImage(with: model.imageURL, placeholder: UIImage(named: "not_found_cover"), options: .setImageWithFadeAnimation, completion: nil)
        }

        let nameNode = LayoutNode(sizeProvider: nameString, config: nil) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let authorNode = LayoutNode(sizeProvider: authorString, config: { node in
            node.marginTop = 16
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = authorString
        }

        let infoNode = LayoutNode(sizeProvider: infoString, config: { node in
            node.marginTop = 4
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = infoString
        }

        let textStackNode = LayoutNode(children: [nameNode, infoNode, authorNode], config: { node in
            node.flexDirection = .column
            node.alignItems = .flexStart
            node.marginLeft = 16
            node.flex = 1
        })

        let contentNode = LayoutNode(children: [coverNode, textStackNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .flexStart
            node.padding(all: 16)
        })

        return contentNode
    }
}
