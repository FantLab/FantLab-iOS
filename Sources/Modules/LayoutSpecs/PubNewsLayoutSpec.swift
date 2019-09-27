import Foundation
import UIKit
import ALLKit
import FLStyle
import FLModels
import FLExtendedModels
import FLText
import FLKit

public final class PubNewsLayoutSpec: ModelLayoutSpec<PubNewsModel> {
    public override func makeNodeFrom(model: PubNewsModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString: NSAttributedString
        let authorString: NSAttributedString?
        let infoString: NSAttributedString?

        do {
            nameString = model.name.attributed()
                .font(Fonts.system.bold(size: 16))
                .foregroundColor(UIColor.black)
                .make()

            infoString = [model.typeName.capitalizedFirstLetter(), model.dateString].compactAndJoin(" - ").nilIfEmpty?.attributed()
                .font(Fonts.system.regular(size: 12))
                .foregroundColor(UIColor.gray)
                .make()

            authorString = FLStringPreview(string: model.authors).value.nilIfEmpty?.attributed()
                .font(Fonts.system.medium(size: 13))
                .foregroundColor(Colors.fantasticBlue)
                .make()
        }

        let nameNode = LayoutNode(sizeProvider: nameString, config: { node in
//            node.paddingTop = 4
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let authorNode = LayoutNode(sizeProvider: authorString, config: { node in
            node.marginTop = 6
            node.isHidden = authorString == nil
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = authorString
        }

        let infoNode = LayoutNode(sizeProvider: infoString, config: { node in
            node.marginTop = 12
            node.isHidden = infoString == nil
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = infoString
        }

        let textStackNode = LayoutNode(children: [nameNode, authorNode, infoNode], config: { node in
            node.marginLeft = 16
            node.marginRight = 12
            node.flexDirection = .column
            node.flex = 1
        })

        let coverNode = LayoutNode(config: { node in
            node.height = 80
            node.width = 60
            node.alignSelf = .flexStart
        }) { (view: UIImageView, _) in
            view.contentMode = .scaleAspectFit

            WebImage.load(url: model.imageURL, into: view)
        }

        let arrowNode = LayoutNode(config: { node in
            node.width = 10
            node.height = 10
        }) { (view: UIImageView, _) in
            view.contentMode = .scaleAspectFit
            view.tintColor = UIColor.lightGray
            view.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
        }

        let contentNode = LayoutNode(children: [coverNode, textStackNode, arrowNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: 16, left: 12, bottom: 16, right: 12)
        })

        return contentNode
    }
}
