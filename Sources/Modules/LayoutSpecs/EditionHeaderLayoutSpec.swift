import Foundation
import UIKit
import ALLKit
import FLKit
import FLStyle
import FLModels

public final class EditionHeaderLayoutSpec: ModelLayoutSpec<EditionModel> {
    public override func makeNodeFrom(model: EditionModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString: NSAttributedString
        let typeString: NSAttributedString?

        do {
            nameString = model.name.attributed()
                .font(Fonts.system.bold(size: TitleFontSizeRule.fontSizeFor(length: model.name.count)))
                .foregroundColor(UIColor.black)
                .hyphenationFactor(1)
                .alignment(.center)
                .make()

            if !model.type.isEmpty {
                typeString = model.type.capitalizedFirstLetter().attributed()
                    .font(Fonts.system.regular(size: 14))
                    .foregroundColor(UIColor.gray)
                    .alignment(.center)
                    .make()
            } else {
                typeString = nil
            }
        }

        let coverNode = LayoutNode(config: { node in
            node.width = 100
            node.height = 150
            node.marginRight = 16
        }) { (view: UIImageView, _) in
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFit

            WebImage.load(url: model.image, into: view, placeholder: UIImage(named: "no_cover"))
        }

        let nameNode = LayoutNode(sizeProvider: nameString, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let typeNode = LayoutNode(sizeProvider: typeString, config: { node in
            node.marginTop = 12
            node.isHidden = typeString == nil
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = typeString
        }

        let rightStackNode = LayoutNode(children: [nameNode, typeNode], config: { node in
            node.flexDirection = .column
            node.alignItems = .center
            node.flex = 1
        })

        let contentNode = LayoutNode(children: [coverNode, rightStackNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(all: 16)
        })

        return contentNode
    }
}
