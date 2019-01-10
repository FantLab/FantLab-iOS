import Foundation
import UIKit
import ALLKit
import YYWebImage
import FantLabModels
import FantLabUtils
import FantLabStyle

final class WorkAwardsLayoutSpec: ModelLayoutSpec<[WorkModel.AwardModel]> {
    override func makeNodeFrom(model: [WorkModel.AwardModel], sizeConstraints: SizeConstraints) -> LayoutNode {
        var iconNodes: [LayoutNode] = []

        model.forEach { award in
            let iconNode = LayoutNode(config: { node in
                node.width = 24
                node.height = 24
                node.marginRight = 16
                node.marginTop = 6
                node.marginBottom = 6
            }) { (imageView: UIImageView, _) in
                imageView.contentMode = .scaleAspectFit
                imageView.yy_setImage(with: award.iconURL, options: .setImageWithFadeAnimation)
            }

            iconNodes.append(iconNode)
        }

        let iconsNode = LayoutNode(children: iconNodes, config: { node in
            node.flexDirection = .row
            node.flexWrap = .wrap
            node.flex = 1
        })

        let arrowNode = LayoutNode(config: { node in
            node.width = 10
            node.height = 10
        }) { (view: UIImageView, _) in
            view.contentMode = .scaleAspectFit
            view.tintColor = UIColor.lightGray
            view.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
        }

        let contentNode = LayoutNode(children: [iconsNode, arrowNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: 6, left: 16, bottom: 6, right: 12)
        })

        return contentNode
    }
}

final class WorkAwardTitleLayoutSpec: ModelLayoutSpec<WorkModel.AwardModel> {
    override func makeNodeFrom(model: WorkModel.AwardModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString: NSAttributedString

        do {
            nameString = (model.rusName.nilIfEmpty ?? model.name).attributed()
                .font(Fonts.system.medium(size: 15))
                .foregroundColor(UIColor.black)
                .make()
        }

        let iconNode = LayoutNode(config: { node in
            node.width = 24
            node.height = 24
        }) { (imageView: UIImageView, _) in
            imageView.contentMode = .scaleAspectFit
            imageView.yy_setImage(with: model.iconURL, options: .setImageWithFadeAnimation)
        }

        let nameNode = LayoutNode(sizeProvider: nameString, config: { node in
            node.marginLeft = 16
            node.flex = 1
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let topNode = LayoutNode(children: [iconNode, nameNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
        })

        let contentNode = LayoutNode(children: [topNode], config: { node in
            node.flexDirection = .column
            node.padding(all: 16)
        })

        return contentNode
    }
}

final class WorkAwardContestLayoutSpec: ModelLayoutSpec<WorkModel.AwardModel.ContestModel> {
    override func makeNodeFrom(model: WorkModel.AwardModel.ContestModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString = [String(model.year), model.name].compactAndJoin(" - ").attributed()
            .font(Fonts.system.regular(size: 13))
            .foregroundColor(UIColor.gray)
            .make()

        let winString: NSAttributedString

        if model.isWin {
            winString = "★".attributed()
                .font(Fonts.system.regular(size: 13))
                .foregroundColor(Colors.ratingColor)
                .make()
        } else {
            winString = "☆".attributed()
                .font(Fonts.system.regular(size: 13))
                .foregroundColor(UIColor.lightGray)
                .make()
        }

        let nameNode = LayoutNode(sizeProvider: nameString, config: { node in
            node.flex = 1
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let winNode = LayoutNode(sizeProvider: winString, config: { node in
            node.marginLeft = 24
        }) { (label: UILabel, _) in
            label.attributedText = winString
        }

        let contentNode = LayoutNode(children: [nameNode, winNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: nil, left: 56, bottom: 16, right: 16)
        })

        return contentNode
    }
}
