import Foundation
import UIKit
import ALLKit
import yoga
import FantLabModels
import FantLabStyle

struct WorkParentModelLayoutModel {
    let work: WorkModel.ParentWorkModel
    let level: Int
    let showArrow: Bool
}

final class WorkParentModelLayoutSpec: ModelLayoutSpec<WorkParentModelLayoutModel> {
    override func makeNodeFrom(model: WorkParentModelLayoutModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString: NSAttributedString
        let typeString: NSAttributedString?

        do {
            nameString = model.work.name.attributed()
                .font(Fonts.system.regular(size: 14))
                .foregroundColor(UIColor.black)
                .make()

            typeString = model.work.workType.nilIfEmpty?.attributed()
                .font(Fonts.system.regular(size: 13))
                .foregroundColor(UIColor.lightGray)
                .make()
        }

        let nameNode = LayoutNode(sizeProvider: nameString, config: { node in
            node.flex = 1
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let typeNode = LayoutNode(sizeProvider: typeString, config: { node in
            node.marginLeft = 12
            node.isHidden = typeString == nil
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = typeString
        }

        let contentNode = LayoutNode(children: [nameNode, typeNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.flex = 1
        })

        let arrowNode = LayoutNode(config: { node in
            node.marginLeft = 8
            node.width = 12
            node.height = 12
            node.isHidden = !model.showArrow
        }) { (view: UIImageView) in
            view.contentMode = .scaleAspectFit
            view.tintColor = UIColor(rgb: 0xC8C7CC)
            view.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
            view.isHidden = !model.showArrow
        }

        let mainNode = LayoutNode(children: [contentNode, arrowNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(
                top: 16,
                left: YGValue(CGFloat(16 * (model.level + 1))),
                bottom: 16,
                right: 12
            )
        })

        return mainNode
    }
}
