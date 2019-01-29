import Foundation
import UIKit
import YYWebImage
import FantLabUtils
import FantLabStyle

public final class ImageBackgroundViewController: UIViewController {
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return Appearance.statusBarStyle
    }

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

    public func moveTo(position value: CGFloat) {
        guard imageView.image != nil else {
            return
        }

        let position = min(1, max(0, value))

        contentView.alpha = 1 - position
        imageView.alpha = position
    }
}
