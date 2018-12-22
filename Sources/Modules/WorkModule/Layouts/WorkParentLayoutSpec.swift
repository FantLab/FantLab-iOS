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
                .font(Fonts.system.medium(size: 14))
                .foregroundColor(UIColor.black)
                .make()

            typeString = model.work.workType.capitalizedFirstLetter().nilIfEmpty?.attributed()
                .font(Fonts.system.regular(size: 12))
                .foregroundColor(UIColor.lightGray)
                .make()
        }

        let nameNode = LayoutNode(sizeProvider: nameString, config: nil) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let typeNode = LayoutNode(sizeProvider: typeString, config: { node in
            node.marginTop = 2
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = typeString
        }

        let textContentNode = LayoutNode(children: [nameNode, typeNode], config: { node in
            node.flexDirection = .column
            node.alignItems = .flexStart
            node.flex = 1
        })

        let arrowNode = LayoutNode(config: { node in
            node.marginLeft = 8
            node.width = 10
            node.height = 10
        }) { (view: UIImageView) in
            view.contentMode = .scaleAspectFit
            view.tintColor = UIColor.lightGray
            view.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
            view.isHidden = !model.showArrow
        }

        let contentNode = LayoutNode(children: [textContentNode, arrowNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(
                top: 16,
                left: YGValue(CGFloat(16 * (model.level + 1))),
                bottom: 16,
                right: 12
            )
        })

        return contentNode
    }
}
