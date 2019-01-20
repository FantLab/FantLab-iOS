import Foundation
import UIKit
import ALLKit
import YYWebImage
import yoga

public final class FLTextImageLoadingLayoutSpec: ModelLayoutSpec<(URL, ((UIImage) -> Void)?)> {
    public override func makeNodeFrom(model: (URL, ((UIImage) -> Void)?), sizeConstraints: SizeConstraints) -> LayoutNode {
        let spinnerNode = LayoutNode(config: { node in
            node.width = 32
            node.height = 32
        }) { (view: UIActivityIndicatorView, _) in
            view.style = .gray
            view.startAnimating()
        }

        let containerNode = LayoutNode(children: [spinnerNode], config: { node in
            node.alignItems = .center
            node.justifyContent = .center
            node.height = 48
        }) { (imageView: UIImageView, _) in
            imageView.yy_setImage(with: model.0, placeholder: nil, options: .avoidSetImage, completion: { (image, _, _, _, _) in
                image.flatMap {
                    model.1?($0)
                }
            })
        }

        return containerNode
    }
}
