import Foundation
import UIKit

public final class Appearance {
    public static func setup() {
        do {
            let appearance = UISegmentedControl.appearance()
            appearance.setTitleTextAttributes([.font: Fonts.system.regular(size: 13)], for: .normal)
            appearance.setTitleTextAttributes([.font: Fonts.system.medium(size: 13)], for: .selected)
        }
    }
}
