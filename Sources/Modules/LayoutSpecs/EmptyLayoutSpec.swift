import Foundation
import UIKit
import ALLKit

public final class EmptyLayoutSpec: LayoutSpec {
    public override func makeNodeWith(sizeConstraints: SizeConstraints) -> LayoutNode {
        return LayoutNode()
    }
}
