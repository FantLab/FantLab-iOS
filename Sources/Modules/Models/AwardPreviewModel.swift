import Foundation

public final class AwardPreviewModel {
    public final class ContestModel {
        public let id: Int
        public let year: Int
        public let name: String
        public let workId: Int
        public let workName: String
        public let isWin: Bool

        public init(id: Int,
                    year: Int,
                    name: String,
                    workId: Int,
                    workName: String,
                    isWin: Bool) {

            self.id = id
            self.year = year
            self.name = name
            self.workId = workId
            self.workName = workName
            self.isWin = isWin
        }
    }

    public let id: Int
    public let name: String
    public let rusName: String
    public let isOpen: Bool
    public let iconURL: URL?
    public let contests: [ContestModel]

    public init(id: Int,
                name: String,
                rusName: String,
                isOpen: Bool,
                iconURL: URL?,
                contests: [ContestModel]) {

        self.id = id
        self.name = name
        self.rusName = rusName
        self.isOpen = isOpen
        self.iconURL = iconURL
        self.contests = contests
    }
}
