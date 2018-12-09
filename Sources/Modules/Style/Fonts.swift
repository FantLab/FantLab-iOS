import UIKit.UIFont

public struct Fonts {
    public static let system = SystemFontsProvider()
    public static let iowan = IowanFontsProvider()
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

public final class IowanFontsProvider {
    public func regular(size: CGFloat) -> UIFont {
        return UIFont(name: "IowanOldStyle-Roman", size: size)!
    }

    public func bold(size: CGFloat) -> UIFont {
        return UIFont(name: "IowanOldStyle-Bold", size: size)!
    }

    public func italic(size: CGFloat) -> UIFont {
        return UIFont(name: "IowanOldStyle-Italic", size: size)!
    }
}
