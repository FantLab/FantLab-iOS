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

        do {
            nameString = model.name.attributed()
                .font(Fonts.system.bold(size: 24))
                .foregroundColor(UIColor.black)
                .make()
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

        let nameNode = LayoutNode(sizeProvider: nameString, config: { node in

        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let leftStackNode = LayoutNode(children: [nameNode], config: { node in
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
