import Foundation
import UIKit
import ALLKit
import yoga
import FantLabUtils
import FantLabStyle
import FantLabModels

final class WorkGenresLayoutSpec: ModelLayoutSpec<WorkModel> {
    override func makeNodeFrom(model: WorkModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        var textStackNodes: [LayoutNode] = []

        model.classificatory.forEach { genreGroup in
            let titleString = genreGroup.title.attributed()
                .font(AppStyle.iowanFonts.regularFont(ofSize: 14))
                .foregroundColor(AppStyle.colors.secondaryTextColor)
                .make()

            let genresString = genreGroup.genres.joined(separator: "\n").attributed()
                .font(AppStyle.iowanFonts.regularFont(ofSize: 14))
                .foregroundColor(AppStyle.colors.mainTextColor)
                .make()

            let titleNode = LayoutNode(sizeProvider: titleString, config: { node in
                node.width = 40%
                node.marginTop = 2
            }) { (label: UILabel) in
                label.numberOfLines = 0
                label.attributedText = titleString
            }

            let genresNode = LayoutNode(sizeProvider: genresString, config: { node in
                node.marginLeft = 16
                node.width = 55%
            }) { (label: UILabel) in
                label.numberOfLines = 0
                label.attributedText = genresString
            }

            let textStackNode = LayoutNode(children: [titleNode, genresNode], config: { node in
                node.flexDirection = .row
                node.alignItems = .flexStart
                node.marginTop = 12
            })

            textStackNodes.append(textStackNode)
        }

        let mainNode = LayoutNode(children: textStackNodes, config: { node in
            node.flexDirection = .column
            node.alignItems = .flexStart
            node.padding(top: nil, left: 16, bottom: 16, right: 16)
        })

        return mainNode
    }
}
