import Foundation
import UIKit
import ALLKit
import FantLabStyle
import FantLabText
import FantLabUtils
import FantLabModels

public final class WorkReviewTextLayoutSpec: ModelLayoutSpec<WorkReviewModel> {
    public override func makeNodeFrom(model: WorkReviewModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let text = FLStringPreview(string: model.text).value.attributed()
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
        }) { (label: AsyncLabel, _) in
            label.stringDrawing = text
        }

        let contentNode = LayoutNode(children: [textNode], config: { node in
            node.padding(all: 16)
        })

        return contentNode
    }
}
