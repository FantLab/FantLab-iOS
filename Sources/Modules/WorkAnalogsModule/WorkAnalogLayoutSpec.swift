import Foundation
import UIKit
import ALLKit
import yoga
import FantLabModels
import FantLabUtils
import FantLabStyle
import FantLabSharedUI

final class WorkAnalogLayoutSpec: ModelLayoutSpec<WorkAnalogModel> {
    override func makeNodeFrom(model: WorkAnalogModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let titleString: NSAttributedString?

        do {
            let authorText = model.authors.first ?? ""
            let nameText = model.name.nilIfEmpty ?? model.nameOrig
            let titleText = [authorText, nameText].compactAndJoin(" - ")

            titleString = titleText.nilIfEmpty?.attributed()
                .font(AppStyle.iowanFonts.boldFont(ofSize: 15))
                .foregroundColor(AppStyle.colors.mainTextColor)
                .make()
        }

        let subtitleString: NSAttributedString?

        do {
            let yearText = model.year > 0 ? String(model.year) : ""
            let subtitleText = [model.workType, yearText].compactAndJoin(", ")

            subtitleString = subtitleText.capitalizedFirstLetter().nilIfEmpty?.attributed()
                .font(AppStyle.systemFonts.regularFont(ofSize: 13))
                .foregroundColor(AppStyle.colors.secondaryTextColor)
                .make()
        }

        let titleNode = LayoutNode(sizeProvider: titleString, config: { node in
            node.isHidden = titleString == nil
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = titleString
        }

        let subtitleNode = LayoutNode(sizeProvider: subtitleString, config: { node in
            node.isHidden = subtitleString == nil
            node.marginTop = 2
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = subtitleString
        }

        let contentStackNode = LayoutNode(children: [titleNode, subtitleNode], config: { node in
            node.flexDirection = .column
            node.alignItems = .flexStart
        })

        return RightArrowLayoutSpec(model: contentStackNode).makeNodeWith(sizeConstraints: sizeConstraints)
    }
}
