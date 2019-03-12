import Foundation
import UIKit

public final class TitleFontSizeRule {
    private init() {}

    public static func fontSizeFor(length: Int) -> CGFloat {
        if length < 10 {
            return 32
        } else if length < 40 {
            return 28
        } else if length < 70 {
            return 24
        } else {
            return 20
        }
    }
}
