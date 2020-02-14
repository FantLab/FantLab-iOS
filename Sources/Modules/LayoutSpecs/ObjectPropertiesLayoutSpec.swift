import Foundation
import UIKit
import ALLKit
import FLKit
import FLModels
import FLStyle
import FLText

public final class ObjectPropertiesLayoutSpec: ModelLayoutSpec<ObjectPropertiesProvider> {
    public override func makeNodeFrom(model: ObjectPropertiesProvider, sizeConstraints: SizeConstraints) -> LayoutNode {
        let properties = model.objectProperties

        var textStackNodes: [LayoutNode] = []

        properties.enumerated().forEach { (index, property) in
            let titleString = property.name.capitalizedFirstLetter().attributed()
                .font(Fonts.system.regular(size: 14))
                .foregroundColor(UIColor.lightGray)
                .make()

            let contentString = property.value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).capitalizedFirstLetter().attributed()
                .font(Fonts.system.regular(size: 14))
                .foregroundColor(UIColor.black)
                .make()

            let titleNode = LayoutNode(sizeProvider: titleString, {
                node.width = 48%
            }) { (label: UILabel, _) in
                label.numberOfLines = 0
                label.attributedText = titleString
            }

            let spacingNode = LayoutNode({
                node.width = 2%
            })

            let contentNode = LayoutNode(sizeProvider: contentString, {
                node.width = 50%
            }) { (label: UILabel, _) in
                label.numberOfLines = 0
                label.attributedText = contentString
            }

            let textStackNode = LayoutNode(children: [titleNode, spacingNode, contentNode], {
                node.flexDirection = .row
                node.alignItems = .flexStart
                node.marginTop = 16
            })

            textStackNodes.append(textStackNode)
        }

        let contentNode = LayoutNode(children: textStackNodes, {
            node.flexDirection = .column
            node.alignItems = .flexStart
            node.padding(top: nil, left: 16, bottom: 16, right: 16)
        })

        return contentNode
    }
}
