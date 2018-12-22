import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabText
import FantLabStyle
import FantLabSharedUI

final class WorkDescriptionLayoutSpec: ModelLayoutSpec<WorkModel> {
    override func makeNodeFrom(model: WorkModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let text = FLAttributedText(
            taggedString: model.descriptionText.nilIfEmpty ?? model.notes,
            decorator: PreviewTextDecorator(),
            replacementRules: TagReplacementRules.previewAttachments
        )

        let textDrawing = text.string.drawing(options: [.truncatesLastVisibleLine,
                                                        .usesFontLeading,
                                                        .usesLineFragmentOrigin])

        let textNode = LayoutNode(sizeProvider: textDrawing, config: { node in
            node.maxHeight = 120
            node.flex = 1
        }) { (label: AsyncLabel) in
            label.stringDrawing = textDrawing
        }

        let arrowNode = LayoutNode(config: { node in
            node.width = 10
            node.height = 10
            node.marginLeft = 12
        }) { (view: UIImageView) in
            view.contentMode = .scaleAspectFit
            view.tintColor = UIColor.lightGray
            view.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
        }

        let contentNode = LayoutNode(children: [textNode, arrowNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: 16, left: 16, bottom: 24, right: 12)
        })

        return contentNode
    }
}
