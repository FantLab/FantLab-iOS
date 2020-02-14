import Foundation
import UIKit
import ALLKit
import FLText

public struct FLComboTextLayoutModel {
    public let text: FLText
    public let openURL: (URL) -> Void

    public init(text: FLText,
                openURL: @escaping (URL) -> Void) {

        self.text = text
        self.openURL = openURL
    }
}

public final class FLComboTextLayoutSpec: ModelLayoutSpec<FLComboTextLayoutModel> {
    public override func makeNodeFrom(model: FLComboTextLayoutModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        var textNodes: [LayoutNode] = []

        model.text.items.forEach { item in
            guard case let .string(content) = item else {
                return
            }

            let textModel = FLTextStringLayoutModel(
                string: content,
                linkAttributes: model.text.decorator.linkAttributes,
                openURL: model.openURL
            )

            let textNode = FLTextStringLayoutSpec(model: textModel).makeNodeWith(sizeConstraints: sizeConstraints)

            textNodes.append(textNode)

            let spacingNode = EmptySpaceLayoutSpec(model: (UIColor.white, 12)).makeNodeWith(sizeConstraints: sizeConstraints)

            textNodes.append(spacingNode)
        }

        let contentNode = LayoutNode(children: textNodes, {
            node.paddingBottom = 4
        })

        return contentNode
    }
}
