import UIKit.UIColor
import FantLabUtils

public struct AppStyle {
    public static let systemFonts: FontsProvider = SystemFontsProvider()
    public static let iowanFonts: FontsProvider = IowanFontsProvider()

    public static let colors: ColorsProvider = ColorsProvider.init(
        mainTintColor: UIColor(rgb: 0x3178A8),
        secondaryTintColor: UIColor(rgb: 0xc45e24),
        viewBackgroundColor: UIColor.white,
        viewShadowColor: UIColor.black.withAlphaComponent(0.1),
        sectionBackgroundColor: #colorLiteral(red: 0.9741742228, green: 0.9741742228, blue: 0.9741742228, alpha: 1),
        separatorColor: #colorLiteral(red: 0.8319705311, green: 0.8319705311, blue: 0.8319705311, alpha: 1),
        arrowColor: UIColor(rgb: 0xC8C7CC),
        mainTextColor: UIColor.black,
        secondaryTextColor: UIColor.lightGray,
        linkTextColor: UIColor(rgb: 0x3178A8),
        textTapAreaForegroundColor: UIColor.white,
        textTapAreaBackgroundColor: UIColor(rgb: 0x3178A8)
    )
}
