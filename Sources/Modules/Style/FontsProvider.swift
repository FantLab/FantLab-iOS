import UIKit.UIFont

public protocol FontsProvider {
    func regularFont(ofSize fontSize: CGFloat) -> UIFont
    func boldFont(ofSize fontSize: CGFloat) -> UIFont
    func italicFont(ofSize fontSize: CGFloat) -> UIFont
}

final class SystemFontsProvider: FontsProvider {
    func regularFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: fontSize)
    }

    func boldFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont.boldSystemFont(ofSize: fontSize)
    }

    func italicFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont.italicSystemFont(ofSize: fontSize)
    }
}

final class IowanFontsProvider: FontsProvider {
    func regularFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "IowanOldStyle-Roman", size: fontSize)!
    }

    func boldFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "IowanOldStyle-Bold", size: fontSize)!
    }

    func italicFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "IowanOldStyle-Italic", size: fontSize)!
    }
}
