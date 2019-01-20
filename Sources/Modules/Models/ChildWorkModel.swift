public final class ChildWorkModel {
    public let id: Int
    public let name: String
    public let origName: String
    public let nameBonus: String
    public let rating: Float
    public let votes: Int
    public let workType: String
    public let workTypeKey: String
    public let publishStatus: String
    public let isPublished: Bool
    public let year: Int
    public let deepLevel: Int
    public let plus: Bool

    public init(id: Int,
                name: String,
                origName: String,
                nameBonus: String,
                rating: Float,
                votes: Int,
                workType: String,
                workTypeKey: String,
                publishStatus: String,
                isPublished: Bool,
                year: Int,
                deepLevel: Int,
                plus: Bool) {

        self.id = id
        self.name = name
        self.origName = origName
        self.nameBonus = nameBonus
        self.rating = rating
        self.votes = votes
        self.workType = workType
        self.workTypeKey = workTypeKey
        self.publishStatus = publishStatus
        self.isPublished = isPublished
        self.year = year
        self.deepLevel = deepLevel
        self.plus = plus
    }
}
