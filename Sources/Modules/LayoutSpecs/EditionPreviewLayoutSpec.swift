import Foundation
import UIKit
import ALLKit
import FLModels
import FLStyle
import FLKit

public final class EditionPreviewLayoutSpec: ModelLayoutSpec<EditionPreviewModel> {
    public override func makeNodeFrom(model: EditionPreviewModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let yearString = (model.year > 0 ? String(model.year) : "-").attributed()
            .font(Fonts.system.regular(size: 12))
            .foregroundColor(UIColor.gray)
            .make()

        let imageNode = LayoutNode({
            node.flex = 1
            node.width = 80%
        }) { (imageView: UIImageView, _) in
            imageView.contentMode = .scaleAspectFit

            WebImage.load(url: model.coverURL, into: imageView, placeholder: UIImage(named: "no_cover"))
        }

        let yearNode = LayoutNode(sizeProvider: yearString, config: nil) { (label: UILabel, _) in
            label.attributedText = yearString
        }

        let dotNode = LayoutNode({
            node.width = 8
            node.height = 8
            node.marginRight = 4
            node.isHidden = !(model.year > 0)
        }) { (view: UIView, _) in
            view.layer.cornerRadius = 4

            if model.correctLevel < 0.5 {
                view.backgroundColor = UIColor(rgb: 0xff0000)
            } else if model.correctLevel < 1 {
                view.backgroundColor = UIColor(rgb: 0xffa500)
            } else {
                view.backgroundColor = UIColor(rgb: 0x008000)
            }
        }

        let bottomNode = LayoutNode(children: [dotNode, yearNode], {
            node.marginTop = 8
            node.flexDirection = .row
            node.alignItems = .center
        })

        let contentNode = LayoutNode(children: [imageNode, bottomNode], {
            node.padding(all: 8)
            node.flexDirection = .column
            node.alignItems = .center
        })

        return contentNode
    }
}
