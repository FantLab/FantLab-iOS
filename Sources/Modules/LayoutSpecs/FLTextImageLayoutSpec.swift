import Foundation
import UIKit
import ALLKit
import YYWebImage
import yoga

public typealias FLTextImageLayoutModel = (image: UIImage, alwaysFullScreen: Bool)

public final class FLTextImageLayoutSpec: ModelLayoutSpec<FLTextImageLayoutModel> {
    public override func makeNodeFrom(model: FLTextImageLayoutModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let imageNode = LayoutNode(children: [], config: { node in
            if !model.alwaysFullScreen, let width = sizeConstraints.width, width > model.image.size.width {
                node.width = YGValue(model.image.size.width)
                node.height = YGValue(model.image.size.height)
            } else {
                node.width = 100%
                node.aspectRatio = Float(model.image.size.width / model.image.size.height)
            }
        }) { (imageView: UIImageView, _) in
            imageView.clipsToBounds = true
            imageView.image = model.image
        }

        return LayoutNode(children: [imageNode], config: { node in
            node.flexDirection = .column
            node.alignItems = .center
        })
    }
}
