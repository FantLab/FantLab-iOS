import Foundation
import UIKit

public final class Appearance {
    private init() {}
    
    public static let statusBarStyle: UIStatusBarStyle = .lightContent

    // не серчбар а хачина!
    public static func setup(searchBar: UISearchBar) {
        searchBar.isTranslucent = false
        searchBar.tintColor = UIColor.white
        searchBar.setSearchFieldBackgroundImage(UIImage.from(color: UIColor.white, size: CGSize(width: 40, height: 36), cornerRadius: 8), for: UIControl.State.normal)
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 4, vertical: 0)

        if let textField: UITextField = searchBar.findChild() {
            textField.textColor = UIColor.black
            textField.tintColor = Colors.flBlue
        }

        searchBar.setValue("Отмена", forKey: "cancelButtonText")
    }

    public static func setup(navigationBar: UINavigationBar) {
        navigationBar.tintColor = UIColor.white
        navigationBar.titleTextAttributes = [.font: Fonts.system.bold(size: 18), .foregroundColor: UIColor.white]
        navigationBar.barTintColor = Colors.flBlue
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage.from(color: Colors.flBlue), for: .default)
    }

    public static func setup(segmentedControl: UISegmentedControl) {
        segmentedControl.setTitleTextAttributes([.font: Fonts.system.regular(size: 13)], for: .normal)
        segmentedControl.setTitleTextAttributes([.font: Fonts.system.medium(size: 13)], for: .selected)
    }
}
