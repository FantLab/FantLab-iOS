import Foundation
import UIKit
import ALLKit
import yoga
import FantLabUtils
import FantLabStyle
import FantLabModels

public final class WorkGenresLayoutSpec: ModelLayoutSpec<WorkModel> {
    public override func makeNodeFrom(model: WorkModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        var textStackNodes: [LayoutNode] = []

        model.classificatory.enumerated().forEach { (index, genreGroup) in
            let titleString = genreGroup.title.attributed()
                .font(Fonts.system.regular(size: 13))
                .foregroundColor(UIColor.lightGray)
                .make()

            let genresString = genreGroup.genres.map({ $0.label }).prefix(2).joined(separator: "\n").attributed()
                .font(Fonts.system.regular(size: 13))
                .foregroundColor(UIColor.black)
                .make()

            let titleNode = LayoutNode(sizeProvider: titleString, config: { node in
                node.width = 40%
            }) { (label: UILabel, _) in
                label.numberOfLines = 0
                label.attributedText = titleString
            }

            let genresNode = LayoutNode(sizeProvider: genresString, config: { node in
                node.marginLeft = 16
                node.width = 55%
            }) { (label: UILabel, _) in
                label.numberOfLines = 0
                label.attributedText = genresString
            }

            let textStackNode = LayoutNode(children: [titleNode, genresNode], config: { node in
                node.flexDirection = .row
                node.alignItems = .flexStart
                node.marginTop = 16
            })

            textStackNodes.append(textStackNode)
        }

        let contentNode = LayoutNode(children: textStackNodes, config: { node in
            node.flexDirection = .column
            node.alignItems = .flexStart
            node.padding(top: nil, left: 16, bottom: 16, right: 16)
        })

        return contentNode
    }
}
