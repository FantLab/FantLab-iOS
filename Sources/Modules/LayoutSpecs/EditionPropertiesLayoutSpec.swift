import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabStyle
import FantLabText

public final class EditionPropertiesLayoutSpec: ModelLayoutSpec<EditionModel> {
    public override func makeNodeFrom(model: EditionModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let publisher = FLStringPreview(string: model.publisher).value

        var properties: [(String, String)] = []

        if !model.lang.isEmpty {
            properties.append(("Язык", model.lang))
        }

        if !model.planDate.isEmpty {
            properties.append(("Дата выхода", model.planDate))
        } else if model.year > 0 {
            properties.append(("Год", String(model.year)))
        }

        if !publisher.isEmpty {
            properties.append(("Издатель", publisher))
        }

        if !model.coverType.isEmpty {
            properties.append(("Тип обложки", model.coverType))
        }

        if model.copies > 0 {
            properties.append(("Тираж", String(model.copies)))
        }

        if model.pages > 0 {
            properties.append(("Страниц", String(model.pages)))
        }

        if !model.format.isEmpty {
            properties.append(("Формат", model.format))
        }

        if !model.isbn.isEmpty {
            properties.append(("ISBN", model.isbn))
        }

        var textStackNodes: [LayoutNode] = []

        properties.enumerated().forEach { (index, property) in
            let titleString = property.0.capitalizedFirstLetter().attributed()
                .font(Fonts.system.regular(size: 14))
                .foregroundColor(UIColor.lightGray)
                .make()

            let contentString = property.1.capitalizedFirstLetter().attributed()
                .font(Fonts.system.regular(size: 14))
                .foregroundColor(UIColor.black)
                .make()

            let titleNode = LayoutNode(sizeProvider: titleString, config: { node in
                node.width = 40%
            }) { (label: UILabel, _) in
                label.numberOfLines = 0
                label.attributedText = titleString
            }

            let contentNode = LayoutNode(sizeProvider: contentString, config: { node in
                node.marginLeft = 16
                node.width = 55%
            }) { (label: UILabel, _) in
                label.numberOfLines = 0
                label.attributedText = contentString
            }

            let textStackNode = LayoutNode(children: [titleNode, contentNode], config: { node in
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
