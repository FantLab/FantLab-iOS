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
        case rss = "EEE, d MMM yyyy HH:mm:ss Z"
    }

    private struct Symbols {
        public static let altShortMonthSymbols = ["янв", "фев", "мар", "апр", "май", "июн", "июл", "авг", "сен", "окт", "ноя", "дек"]
    }

    public func formatToHumanReadbleText() -> String {
        if Calendar.rus.isDateInToday(self) {
            return "Сегодня"
        } else if Calendar.rus.isDateInYesterday(self) {
            return "Вчера"
        } else {
            return format(Date().year == self.year ? .dayAndMonth : .dayMonthAndYear)
        }
    }

    public func format(_ format: Format) -> String {
        return self.format(format.rawValue)
    }

    public func format(_ format: String) -> String {
        let dateFormatter = DateFormatter(
            locale: Locale.ru,
            calendar: Calendar.rus,
            dateFormat: format
        )

        return dateFormatter.string(from: self)
    }

    public static func from(string: String,
                            format: Format,
                            useAltShortMonthSymbols: Bool = false) -> Date? {
        return from(
            string: string,
            format: format.rawValue,
            useAltShortMonthSymbols: useAltShortMonthSymbols
        )
    }

    public static func from(string: String,
                            format: String,
                            useAltShortMonthSymbols: Bool = false) -> Date? {
        let dateFormatter = DateFormatter(
            locale: Locale.ru,
            calendar: Calendar.rus,
            dateFormat: format
        )

        if useAltShortMonthSymbols {
            dateFormatter.shortMonthSymbols = Symbols.altShortMonthSymbols
        }

        return dateFormatter.date(from: string)
    }

    public func component(_ component: Calendar.Component) -> Int {
        return Calendar.rus.component(component, from: self)
    }

    public var year: Int {
        return component(.year)
    }
}
