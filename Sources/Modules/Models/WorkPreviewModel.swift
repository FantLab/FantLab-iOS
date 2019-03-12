import Foundation

public final class WorkPreviewModel {
    public let id: Int
    public let name: String
    public let type: String
    public let typeId: Int
    public let year: Int
    public let authors: [String]
    public let rating: Float
    public let votes: Int

    public init(id: Int,
                name: String,
                type: String,
                typeId: Int,
                year: Int,
                authors: [String],
                rating: Float,
                votes: Int) {

        self.id = id
        self.name = name
        self.type = type
        self.typeId = typeId
        self.year = year
        self.authors = authors
        self.rating = rating
        self.votes = votes
    }
}
