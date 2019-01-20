import Foundation
import UIKit
import ALLKit
import FantLabStyle

public final class ShowAllButtonLayoutSpec: ModelLayoutSpec<String> {
    public override func makeNodeFrom(model: String, sizeConstraints: SizeConstraints) -> LayoutNode {
        let titleString = model.attributed()
            .font(Fonts.system.medium(size: 17))
            .foregroundColor(Colors.flOrange)
            .make()

        let textNode = LayoutNode(sizeProvider: titleString, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = titleString
        }

        return LayoutNode(children: [textNode], config: { node in
            node.alignItems = .center
            node.justifyContent = .center
            node.padding(all: 24)
        })
    }
}
