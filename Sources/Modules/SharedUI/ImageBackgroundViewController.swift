import Foundation
import UIKit
import YYWebImage
import FantLabUtils

extension UIViewController {
    public var imageBackgroundViewController: ImageBackgroundViewController? {
        var vc = parent

        while vc != nil {
            if vc is ImageBackgroundViewController {
                return vc as? ImageBackgroundViewController
            }

            vc = vc?.parent
        }

        return nil
    }
}

public final class ImageBackgroundViewController: UIViewController {
    private let imageView = UIImageView()

    public override func viewDidLoad() {
        super.viewDidLoad()

        imageView.backgroundColor = UIColor.black
        imageView.contentMode = .scaleAspectFit

        view.addSubview(imageView)
        imageView.pinEdges(to: view)

        view.addSubview(contentView)
        contentView.pinEdges(to: view)
    }

    // MARK: -

    public let contentView = UIView()

    public var imageURL: URL? {
        didSet {
            imageView.yy_setImage(with: imageURL, placeholder: nil)
        }
    }

    public var position: CGFloat = 0 {
        didSet {
            let value = min(1, max(0, position))

            move(to: value)
        }
    }

    // MARK: -

    private func move(to position: CGFloat) {
        contentView.alpha = 1 - position
        imageView.alpha = position
    }
}
