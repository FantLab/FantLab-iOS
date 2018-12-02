public final class RussianPluralRule {
    public enum Category {
        case one
        case few
        case many
    }

    public struct Format {
        public let one: String
        public let few: String
        public let many: String

        public init(one: String, few: String, many: String) {
            self.one = one
            self.few = few
            self.many = many
        }
    }

    private init() {}

    private static func categoryFrom(value: Int) -> Category {
        if (11...19).contains(value % 100) {
            return .many
        }

        switch value % 10 {
        case 1:
            return .one
        case 2,3,4:
            return .few
        default:
            return .many
        }
    }

    public static func format(value: Int, _ format: Format) -> String {
        let categoryString: String

        switch categoryFrom(value: value) {
        case .one:
            categoryString = format.one
        case .few:
            categoryString = format.few
        case .many:
            categoryString = format.many
        }

        return String(value) + " " + categoryString
    }
}

extension RussianPluralRule.Format {
    public static let votes = RussianPluralRule.Format(
        one: "оценка",
        few: "оценки",
        many: "оценок"
    )
}
