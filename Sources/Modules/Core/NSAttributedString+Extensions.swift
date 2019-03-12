import Foundation
import UIKit

extension NSAttributedString {
    public var fullRange: NSRange {
        return NSMakeRange(0, length)
    }
}

public func + (x: NSAttributedString, y: NSAttributedString) -> NSAttributedString {
    return x.concatenate(with: y)
}

public func += (x: inout NSAttributedString, y: NSAttributedString) {
    x = x + y
}

extension NSAttributedString {
    public func concatenate(with attributedString: NSAttributedString) -> NSAttributedString {
        let x = NSMutableAttributedString()

        x.append(self)
        x.append(attributedString)

        return x
    }
}
