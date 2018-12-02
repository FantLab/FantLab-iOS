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
            node.maxHeight = 150
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = text.string
        }

        return RightArrowLayoutSpec(model: textNode).makeNodeWith(sizeConstraints: sizeConstraints)
    }
}
