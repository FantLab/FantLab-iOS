import Foundation
import UIKit
import ALLKit
import FLModels
import FLStyle
import FLKit

public final class AuthorHeaderLayoutSpec: ModelLayoutSpec<(AuthorModel, () -> Void)> {
    public override func makeNodeFrom(model: (AuthorModel, () -> Void), sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString: NSAttributedString
        let websiteString: NSAttributedString?

        do {
            let nameText = model.0.name.nilIfEmpty ?? model.0.origName

            nameString = nameText.attributed()
                .font(Fonts.system.bold(size: TitleFontSizeRule.fontSizeFor(length: nameText.count)))
                .foregroundColor(UIColor.black)
                .hyphenationFactor(1)
                .make()

            if !model.0.sites.isEmpty {
                websiteString = "Веб-сайт".attributed()
                    .font(Fonts.system.medium(size: 15))
                    .foregroundColor(Colors.fantasticBlue)
                    .make()
            } else {
                websiteString = nil
            }
        }

        let imageNode = LayoutNode(config: { node in
            node.width = 80
            node.height = 80
            node.marginLeft = 16
        }) { (view: UIImageView, _) in
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFill
            view.layer.cornerRadius = 40
            view.backgroundColor = Colors.perfectGray

            WebImage.load(url: model.0.imageURL, into: view)
        }

        let nameNode = LayoutNode(sizeProvider: nameString, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let websiteNode = LayoutNode(sizeProvider: websiteString, config: { node in
            node.isHidden = websiteString == nil
            node.marginTop = 12
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.isUserInteractionEnabled = true
            label.attributedText = websiteString
            label.all_addGestureRecognizer({ [weak label] (_: UITapGestureRecognizer) in
                label?.animated(action: model.1, alpha: 0.3)
            })
        }

        let textStackNode = LayoutNode(children: [nameNode, websiteNode], config: { node in
            node.flexDirection = .column
            node.alignItems = .flexStart
            node.flex = 1
        })

        let contentNode = LayoutNode(children: [textStackNode, imageNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: 32, left: 16, bottom: 32, right: 16)
        })

        return contentNode
    }
}
