import Foundation

public final class MyBookModel {
    public enum Group: Int, CaseIterable, CustomStringConvertible {
        case favorites = 1
        case wantToRead

        public var description: String {
            switch self {
            case .favorites:
                return "Избранное"
            case .wantToRead:
                return "Хочу почитать"
            }
        }
    }

    public let id: Int
    public let group: Group
    public let date: Date

    public init(id: Int,
                group: Group,
                date: Date) {

        self.id = id
        self.group = group
        self.date = date
    }
}
