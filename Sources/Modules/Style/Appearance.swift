import Foundation
import UIKit

public final class Appearance {
    private init() {}
    
    public static let statusBarStyle: UIStatusBarStyle = .lightContent

    public static func setup(navigationBar: UINavigationBar) {
        navigationBar.tintColor = UIColor.white
        navigationBar.titleTextAttributes = [.font: Fonts.system.bold(size: 18), .foregroundColor: UIColor.white]
        navigationBar.barTintColor = Colors.flBlue
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
    }

    public static func setup(segmentedControl: UISegmentedControl) {
        segmentedControl.tintColor = Colors.flBlue
        segmentedControl.setTitleTextAttributes([.font: Fonts.system.regular(size: 13)], for: .normal)
        segmentedControl.setTitleTextAttributes([.font: Fonts.system.medium(size: 13)], for: .selected)
    }
}
