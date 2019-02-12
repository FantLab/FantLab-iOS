import Foundation

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
