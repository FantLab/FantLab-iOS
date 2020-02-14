import Foundation
import UIKit
import ALLKit

public final class SpinnerLayoutSpec: LayoutSpec {
    public override func makeNodeWith(boundingDimensions: LayoutDimensions<CGFloat>) -> LayoutNodeConvertible {
        return LayoutNodeBuilder().layout {
            $0.alignItems(.center).justifyContent(.center).height(100)
        }.body {
            LayoutNodeBuilder().layout {
                $0.width(32).height(32)
            }.view { (view: UIActivityIndicatorView, _) in
                view.style = .gray
                view.startAnimating()
            }
        }
    }
}
