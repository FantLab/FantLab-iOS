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

        let textNode = LayoutNode(sizeProvider: text.string, config: { node in
            node.maxHeight = 200
        }) { (label: AsyncLabel) in
            label.text = text.string
        }

        let backgroundNode = LayoutNode(children: [textNode], config: { node in
            node.padding(top: 8, left: 12, bottom: 8, right: 12)
            node.marginLeft = 12
            node.marginRight = 12
            node.flexDirection = .column
        }) { (view: UIView) in
            view.backgroundColor = UIColor(rgb: 0xEFEFF4) //.withAlphaComponent(0.7)
            view.layer.cornerRadius = 8
        }

        return LayoutNode(children: [backgroundNode])
    }
}
