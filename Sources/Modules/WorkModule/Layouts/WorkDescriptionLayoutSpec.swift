import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabText
import FantLabStyle

final class WorkDescriptionLayoutSpec: ModelLayoutSpec<WorkModel> {
    override func makeNodeFrom(model: WorkModel) -> LayoutNode {
        let text = FLAttributedText(
            taggedString: model.descriptionText,
            decorator: PreviewTextDecorator(),
            replacementRules: TagReplacementRules.previewAttachments
        )

        let textNode = LayoutNode(sizeProvider: text.string, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = text.string
        }

        return LayoutNode(children: [textNode], config: { node in
            node.padding(top: 16, left: 16, bottom: 16, right: 0)
            node.maxHeight = 150
        })
    }
}
