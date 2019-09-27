import Foundation
import UIKit
import ALLKit
import FLStyle
import FLText
import FLKit
import FLModels

public final class WorkReviewWorkShortHeaderLayoutSpec: ModelLayoutSpec<WorkReviewModel> {
    public override func makeNodeFrom(model: WorkReviewModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let workNameString: NSAttributedString
        let workAuthorString: NSAttributedString?

        do {
            workNameString = model.work.name.attributed()
                .font(Fonts.system.bold(size: 16))
                .foregroundColor(UIColor.black)
                .make()

            workAuthorString = model.work.authors.compactAndJoin(", ").nilIfEmpty?.attributed()
                .font(Fonts.system.regular(size: 13))
                .foregroundColor(UIColor.lightGray)
                .make()
        }

        let nameNode = LayoutNode(sizeProvider: workNameString, config: { node in

        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = workNameString
        }

        let authorNode: LayoutNode?

        if let string = workAuthorString {
            authorNode = LayoutNode(sizeProvider: string, config: { node in
                node.marginTop = 4
            }) { (label: UILabel, _) in
                label.numberOfLines = 0
                label.attributedText = string
            }
        } else {
            authorNode = nil
        }

        let contentNode = LayoutNode(children: [nameNode, authorNode], config: { node in
            node.flexDirection = .column
            node.alignItems = .flexStart
            node.padding(top: 16, left: 16, bottom: nil, right: 16)
        })

        return contentNode
    }
}
