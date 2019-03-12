import Foundation
import UIKit
import ALLKit
import FLModels
import FLText
import FLStyle

public final class FLTextPreviewLayoutSpec: ModelLayoutSpec<FLStringPreview> {
    public override func makeNodeFrom(model: FLStringPreview, sizeConstraints: SizeConstraints) -> LayoutNode {
        let text = model.value.attributed()
            .font(Fonts.system.regular(size: 15))
            .foregroundColor(UIColor.black)
            .lineSpacing(3)
            .paragraphSpacing(12)
            .make()
            .drawing(options: [
                .truncatesLastVisibleLine,
                .usesFontLeading,
                .usesLineFragmentOrigin
                ])

        let textNode = LayoutNode(sizeProvider: text, config: { node in
            node.maxHeight = 120
            node.flex = 1
        }) { (label: AsyncLabel, _) in
            label.stringDrawing = text
        }

        let arrowNode = LayoutNode(config: { node in
            node.width = 10
            node.height = 10
            node.marginLeft = 12
        }) { (view: UIImageView, _) in
            view.contentMode = .scaleAspectFit
            view.tintColor = UIColor.lightGray
            view.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
        }

        let contentNode = LayoutNode(children: [textNode, arrowNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: 16, left: 16, bottom: 16, right: 12)
        })

        return contentNode
    }
}
