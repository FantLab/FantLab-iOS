import Foundation
import UIKit
import ALLKit
import FLModels
import FLStyle
import FLKit

public final class AuthorHeaderLayoutSpec: ModelLayoutSpec<(AuthorModel, () -> Void)> {
    public override func makeNodeWith(boundingDimensions: LayoutDimensions<CGFloat>) -> LayoutNodeConvertible {
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

        let imageNode = LayoutNode({
            $0.width(80).height(80).margin(.left(16))
        }) { (view: UIImageView, _) in
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFill
            view.layer.cornerRadius = 40
            view.backgroundColor = Colors.perfectGray

            WebImage.load(url: self.model.0.imageURL, into: view)
        }

        let nameNode = LayoutNode(sizeProvider: nameString) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let websiteNode = LayoutNode(sizeProvider: websiteString, {
            $0.isHidden(websiteString == nil).margin(.top(12))
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.isUserInteractionEnabled = true
            label.attributedText = websiteString
            label.all_addGestureRecognizer({ [weak label] (_: UITapGestureRecognizer) in
                label?.animated(action: self.model.1, alpha: 0.3)
            })
        }

        let textStackNode = LayoutNode(children: [nameNode, websiteNode], {
            $0.flexDirection(.column).alignItems(.flexStart).flex(1)
        })

        let contentNode = LayoutNode(children: [textStackNode, imageNode], {
            $0.flexDirection(.row).alignItems(.center).padding(.vertical(32), .horizontal(16))
        })

        return contentNode
    }
}
