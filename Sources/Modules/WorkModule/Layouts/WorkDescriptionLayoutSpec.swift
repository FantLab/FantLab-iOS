import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabText
import FantLabStyle
import FantLabSharedUI

final class WorkDescriptionLayoutSpec: ModelLayoutSpec<WorkModel> {
    override func makeNodeFrom(model: WorkModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let text = FLStringPreview(string: model.descriptionText.nilIfEmpty ?? model.notes).value.attributed()
            .font(Fonts.system.regular(size: 15))
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
