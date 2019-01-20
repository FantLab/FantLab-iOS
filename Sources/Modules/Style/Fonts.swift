import UIKit.UIFont

public struct Fonts {
    public static let system = SystemFontsProvider()
}

public final class SystemFontsProvider {
    public func regular(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size)
    }

    public func medium(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.medium)
    }

    public func bold(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.bold)
    }

    public func italic(size: CGFloat) -> UIFont {
        return UIFont.italicSystemFont(ofSize: size)
    }
}
