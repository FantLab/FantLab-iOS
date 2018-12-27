import Foundation
import UIKit
import ALLKit
import YYWebImage
import yoga

final class ImageLoadingLayoutSpec: ModelLayoutSpec<(URL, ((UIImage) -> Void)?)> {
    override func makeNodeFrom(model: (URL, ((UIImage) -> Void)?), sizeConstraints: SizeConstraints) -> LayoutNode {
        let spinnerNode = LayoutNode(config: { node in
            node.width = 32
            node.height = 32
        }) { (view: UIActivityIndicatorView) in
            view.style = .gray
            view.startAnimating()
        }

        let containerNode = LayoutNode(children: [spinnerNode], config: { node in
            node.alignItems = .center
            node.justifyContent = .center
            node.height = 48
        }) { (imageView: UIImageView) in
            imageView.yy_setImage(with: model.0, placeholder: nil, options: .avoidSetImage, completion: { (image, _, _, _, _) in
                image.flatMap {
                    model.1?($0)
                }
            })
        }

        return containerNode
    }
}

final class ImageLayoutSpec: ModelLayoutSpec<UIImage> {
    override func makeNodeFrom(model: UIImage, sizeConstraints: SizeConstraints) -> LayoutNode {
        let imageNode = LayoutNode(children: [], config: { node in
            if let width = sizeConstraints.width, width > model.size.width {
                node.width = YGValue(model.size.width)
                node.height = YGValue(model.size.height)
            } else {
                node.width = 100%
                node.aspectRatio = Float(model.size.width / model.size.height)
            }
        }) { (imageView: UIImageView) in
            imageView.clipsToBounds = true
            imageView.image = model
        }

        return LayoutNode(children: [imageNode], config: { node in
            node.flexDirection = .column
            node.alignItems = .center
        })
    }
}
