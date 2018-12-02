import Foundation
import UIKit
import ALLKit
import YYWebImage
import FantLabUtils
import FantLabStyle
import FantLabModels

final class WorkHeaderLayoutSpec: ModelLayoutSpec<WorkModel> {
    override func makeNodeFrom(model: WorkModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString: NSAttributedString?

        do {
            let nameText = [model.name, model.origName].compactAndJoin(" / ")

            nameString = nameText.nilIfEmpty?.attributed()
                .font(AppStyle.iowanFonts.boldFont(ofSize: 24))
                .foregroundColor(AppStyle.colors.mainTextColor)
                .make()
        }

        let authorString: NSAttributedString?

        do {
            let authorText = model.authors.map({ $0.name }).compactAndJoin(", ")

            authorString = authorText.nilIfEmpty?.attributed()
                .font(AppStyle.iowanFonts.boldFont(ofSize: 14))
                .foregroundColor(AppStyle.colors.linkTextColor)
                .make()
        }

        let infoString: NSAttributedString?

        do {
            let yearText = model.year > 0 ? String(model.year) : ""
            let infoText = ([model.workType, yearText] + model.publishStatuses).compactAndJoin(", ")

            infoString = infoText.nilIfEmpty?.attributed()
                .font(AppStyle.systemFonts.regularFont(ofSize: 12))
                .foregroundColor(AppStyle.colors.secondaryTextColor)
                .make()
        }

        let nameNode = LayoutNode(sizeProvider: nameString, config: nil) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let authorNode = LayoutNode(sizeProvider: authorString, config: { node in
            node.marginTop = 4
            node.maxHeight = 40
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = authorString
        }

        let infoNode = LayoutNode(sizeProvider: infoString, config: { node in
            node.marginTop = 6
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = infoString
        }

        let contentNode = LayoutNode(children: [nameNode, authorNode, infoNode], config: { node in
            node.flexDirection = .column
            node.padding(all: 16)
        })

        return contentNode
    }
}
