import Foundation
import UIKit
import ALLKit
import FLStyle

public final class FLTextCollapsedHiddenStringLayoutSpec: ModelLayoutSpec<String> {
    public override func makeNodeWith(boundingDimensions: LayoutDimensions<CGFloat>) -> LayoutNodeConvertible {
        let nameString = model.attributed()
            .font(Fonts.system.bold(size: 14))
            .foregroundColor(UIColor.black)
            .make()

        let showContentString = "Показать".attributed()
            .font(Fonts.system.medium(size: 17))
            .foregroundColor(Colors.darkOrange)
            .make()

        let nameTextNode = LayoutNode(sizeProvider: nameString, {
            $0.margin(.bottom(4), .left(8))
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let showContentNode = LayoutNode(sizeProvider: showContentString) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = showContentString
        }

        let borderNode = LayoutNode(children: [showContentNode], {
            $0.padding(.all(16)).flexDirection(.column).alignItems(.center).alignSelf(.stretch)
        }) { (view: UIView, _) in
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.backgroundColor = Colors.perfectGray
        }

        let contentNode = LayoutNode(children: [nameTextNode, borderNode], {
            $0.padding(.horizontal(16)).flexDirection(.column).alignItems(.flexStart)
        })

        return contentNode
    }
}
