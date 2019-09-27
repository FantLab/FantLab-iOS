import Foundation
import UIKit
import RxSwift
import ALLKit
import yoga
import FLKit

public struct FLTextImageLoadingLayoutModel {
    public let url: URL
    public let disposeBag: DisposeBag
    public let completion: (UIImage) -> Void

    public init(url: URL,
                disposeBag: DisposeBag,
                completion: @escaping (UIImage) -> Void) {

        self.url = url
        self.disposeBag = disposeBag
        self.completion = completion
    }
}

public final class FLTextImageLoadingLayoutSpec: ModelLayoutSpec<FLTextImageLoadingLayoutModel> {
    public override func makeNodeFrom(model: FLTextImageLoadingLayoutModel, sizeConstraints: SizeConstraints) -> LayoutNode {
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
            WebImage.load(url: model.url).subscribe(onNext: { image in
                model.completion(image)
            }).disposed(by: model.disposeBag)
        }

        return containerNode
    }
}
