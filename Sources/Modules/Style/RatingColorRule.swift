import UIKit.UIColor

public struct RatingColorRule {
    public static func colorFor(rating: Float) -> UIColor {
        if rating < 5 {
            return UIColor(rgb: 0xFF3B30)
        } else if rating < 7 {
            return UIColor.lightGray
        } else {
            return UIColor(rgb: 0x3bb33b)
        }
    }
}
