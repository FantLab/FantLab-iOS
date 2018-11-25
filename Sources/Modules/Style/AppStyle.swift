import UIKit.UIColor
import FantLabUtils

public final class AppStyle {
    public let fonts: FontsProvider
    public let colors: ColorsProvider

    public init(fonts: FontsProvider,
                colors: ColorsProvider) {

        self.fonts = fonts
        self.colors = colors
    }
}

extension AppStyle {
    public static let shared = AppStyle(
        fonts: IowanFontsProvider(),
        colors: ColorsProvider.init(
            viewBackgroundColor: UIColor.white,
            viewShadowColor: UIColor.black.withAlphaComponent(0.1),
            mainTintColor: UIColor(rgb: 0x3178A8),
            secondaryTextColor: UIColor(rgb: 0xc45e24),
            separatorColor: UIColor(rgb: 0xdcdde1),
            arrowColor: UIColor.lightGray,
            textMainColor: UIColor(rgb: 0x1f1f1f),
            textSecondaryColor: UIColor.lightGray,
            textLinkColor: UIColor(rgb: 0x3178A8),
            textTapAreaForegroundColor: UIColor.white,
            textTapAreaBackgroundColor: UIColor(rgb: 0x3178A8)
        )
    )
}
