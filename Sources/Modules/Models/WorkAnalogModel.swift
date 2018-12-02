public final class WorkAnalogModel {
    public let id: Int
    public let name: String
    public let nameOrig: String
    public let workType: String
    public let year: Int
    public let authors: [String]

    public init(id: Int,
                name: String,
                nameOrig: String,
                workType: String,
                year: Int,
                authors: [String]) {

        self.id = id
        self.name = name
        self.nameOrig = nameOrig
        self.workType = workType
        self.year = year
        self.authors = authors
    }
}
