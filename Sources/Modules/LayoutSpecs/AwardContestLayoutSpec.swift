import Foundation
import UIKit
import ALLKit
import FLModels
import FLKit
import FLStyle

public final class AwardContestLayoutSpec: ModelLayoutSpec<AwardPreviewModel.ContestModel> {
    public override func makeNodeFrom(model: AwardPreviewModel.ContestModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let workNameText = model.workName.nilIfEmpty.flatMap({ "«" + $0 + "»" }) ?? ""

        let yearString = model.year > 0 ? String(model.year) : ""

        let nameString = [yearString, model.name, workNameText].compactAndJoin(" - ").attributed()
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

        let nameNode = LayoutNode(sizeProvider: nameString, {
            node.flex = 1
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let winNode = LayoutNode(sizeProvider: winString, {
            node.marginLeft = 24
        }) { (label: UILabel, _) in
            label.attributedText = winString
        }

        let contentNode = LayoutNode(children: [nameNode, winNode], {
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: nil, left: 56, bottom: 16, right: 16)
        })

        return contentNode
    }
}
