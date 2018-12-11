import Foundation
import UIKit
import ALLKit
import yoga
import FantLabUtils
import FantLabStyle
import FantLabSharedUI

struct WorkSectionTitleLayoutModel {
    let title: String
    let icon: UIImage?
    let count: Int
    let showArrow: Bool
}

final class WorkSectionTitleLayoutSpec: ModelLayoutSpec<WorkSectionTitleLayoutModel> {
    override func makeNodeFrom(model: WorkSectionTitleLayoutModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let titleString = model.title.attributed()
            .font(Fonts.system.bold(size: 18))
            .foregroundColor(UIColor.black)
            .make()

        let countString = String(model.count).attributed()
            .font(Fonts.system.regular(size: 17))
            .foregroundColor(UIColor.lightGray)
            .make()

        let iconNode = LayoutNode(config: { node in
            node.width = 24
            node.height = 24
            node.marginRight = 8
            node.isHidden = model.icon == nil
        }) { (view: UIImageView) in
            view.contentMode = .scaleAspectFit
            view.tintColor = UIColor(rgb: 0xc45e24) // UIColor.lightGray
            view.image = model.icon?.withRenderingMode(.alwaysTemplate)
        }

        let titleNode = LayoutNode(sizeProvider: titleString, config: nil) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = titleString
        }

        let countNode = LayoutNode(sizeProvider: countString, config: { node in
            node.marginLeft = 12
            if !model.showArrow {
                node.marginRight = 8
            }
            node.isHidden = model.count < 1
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = countString
        }

        let textStackNode = LayoutNode(children: [titleNode, countNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.justifyContent = .spaceBetween
            node.flex = 1
        })

        let contentNode = LayoutNode(children: [iconNode, textStackNode], config: { node in
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
            node.paddingLeft = 16
            node.paddingRight = 12
        })

        return mainNode
    }
}
