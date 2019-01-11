import Foundation
import UIKit
import ALLKit

extension UIColor {
    public convenience init(rgb: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255,
            blue: CGFloat(rgb & 0x0000FF) / 255,
            alpha: alpha
        )
    }
}

extension Collection {
    public subscript(safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}

extension String {
    public func capitalizedFirstLetter() -> String {
        return isEmpty ? "" : prefix(1).capitalized + dropFirst()
    }
}

extension String {
    public var nilIfEmpty: String? {
        return isEmpty ? nil : self
    }

    public var maybeHasContent: Bool {
        if count < 10 {
            return contains(where: {
                if let unicodeScalar = $0.unicodeScalars.first {
                    return CharacterSet.alphanumerics.contains(unicodeScalar)
                }

                return false
            })
        }

        return true
    }
}

extension Array where Element == String {
    public func compactAndJoin(_ separator: String) -> String {
        return compactMap({ $0.nilIfEmpty }).joined(separator: separator)
    }
}

extension Range where Bound == String.Index {
    public var nsRange: NSRange {
        return NSMakeRange(lowerBound.encodedOffset, upperBound.encodedOffset - lowerBound.encodedOffset)
    }
}

extension NSAttributedString {
    public var fullRange: NSRange {
        return NSMakeRange(0, length)
    }
}

public func + (x: NSAttributedString, y: NSAttributedString) -> NSAttributedString {
    return x.concatenate(with: y)
}

public func += (x: inout NSAttributedString, y: NSAttributedString) {
    x = x + y
}

extension NSAttributedString {
    public func concatenate(with attributedString: NSAttributedString) -> NSAttributedString {
        let x = NSMutableAttributedString()

        x.append(self)
        x.append(attributedString)

        return x
    }
}

extension Locale {
    public static let ru = Locale(identifier: "ru_RU")
}

extension Calendar {
    public init(identifier: Calendar.Identifier, locale: Locale) {
        self.init(identifier: identifier)
        self.locale = locale
    }

    public static let rus = Calendar(identifier: .gregorian, locale: Locale.ru)
}

extension DateFormatter {
    public convenience init(locale: Locale, calendar: Calendar, dateFormat: String) {
        self.init()
        self.locale = locale
        self.calendar = calendar
        self.dateFormat = dateFormat
    }
}

extension Date {
    public enum Format: String {
        case hoursAndMinutes = "HH:mm"
        case dayAndMonth = "d MMMM"
        case monthAndYear = "LLLL yyyy"
        case dayMonthAndYear = "d MMMM yyyy"
        case dayMonthYearTime = "d MMMM yyyy HH:mm"
    }

    public func formatDayMonthAndYearIfNotCurrent() -> String {
        return format(Date().year == self.year ? .dayAndMonth : .dayMonthAndYear)
    }

    public func format(_ format: Format) -> String {
        return self.format(format.rawValue)
    }

    public func format(_ format: String) -> String {
        return DateFormatter(locale: Locale.ru, calendar: Calendar.rus, dateFormat: format).string(from: self)
    }

    public static func from(string: String, format: String) -> Date? {
        return DateFormatter(locale: Locale.ru, calendar: Calendar.rus, dateFormat: format).date(from: string)
    }

    public func component(_ component: Calendar.Component) -> Int {
        return Calendar.rus.component(component, from: self)
    }

    public var year: Int {
        return component(.year)
    }
}

extension URL {
    public static func from(string: String,
                            defaultHost: String? = nil,
                            defaultScheme: String = "https") -> URL? {
        guard
            !string.isEmpty,
            var components = URLComponents(string: string),
            !components.path.isEmpty else {
                return nil
        }

        if components.host == nil {
            components.host = defaultHost
        }

        if components.scheme == nil {
            components.scheme = defaultScheme
        }

        return components.url
    }
}

extension UIScreen {
    public var px: CGFloat {
        return 1.0/scale
    }
}

extension UIImage {
    public func with(orientation: UIImage.Orientation) -> UIImage? {
        guard let cgImage = cgImage else {
            return nil
        }

        return UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
    }
}

extension ListItem {
    public convenience init(id: String, layoutSpec: LayoutSpec) {
        self.init(id: id, model: id, layoutSpec: layoutSpec)
    }
}

extension UIViewController {
    public func parentVC<T: UIViewController>() -> T? {
        return (parent as? T) ?? parent?.parentVC()
    }
}
