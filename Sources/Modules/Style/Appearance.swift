import Foundation
import UIKit

public final class Appearance {
    public static func setup() {
        do {
            let appearance = UISegmentedControl.appearance()
            appearance.setTitleTextAttributes([.font: AppStyle.iowanFonts.regularFont(ofSize: 13)], for: .normal)
            appearance.setTitleTextAttributes([.font: AppStyle.iowanFonts.boldFont(ofSize: 13)], for: .selected)
        }
    }
}
