import Foundation
import UIKit
import ALLKit
import YYWebImage
import FantLabUtils
import FantLabStyle
import FantLabModels

public final class EditionHeaderLayoutSpec: ModelLayoutSpec<EditionModel> {
    public override func makeNodeFrom(model: EditionModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString: NSAttributedString
        let typeString: NSAttributedString?

        do {
            nameString = model.name.attributed()
                .font(Fonts.system.bold(size: TitleFontSizeRule.fontSizeFor(length: model.name.count)))
                .foregroundColor(UIColor.black)
                .make()

            if !model.type.isEmpty {
                typeString = model.type.capitalizedFirstLetter().attributed()
                    .font(Fonts.system.regular(size: 14))
                    .foregroundColor(UIColor.lightGray)
                    .make()
            } else {
                typeString = nil
            }
        }

        let coverNode = LayoutNode(config: { node in
            node.width = 120
            node.height = 160
            node.marginLeft = 16
        }) { (view: UIImageView, _) in
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFit

            view.yy_setImage(with: model.image, placeholder: UIImage(named: "not_found_cover"), options: .setImageWithFadeAnimation, completion: nil)
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

        let leftStackNode = LayoutNode(children: [nameNode, typeNode], config: { node in
            node.flexDirection = .column
            node.alignItems = .flexStart
            node.flex = 1
        })

        let contentNode = LayoutNode(children: [leftStackNode, coverNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(all: 16)
        })

        return contentNode
    }
}
