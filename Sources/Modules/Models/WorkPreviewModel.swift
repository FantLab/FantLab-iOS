import Foundation

public final class WorkPreviewModel {
    public let id: Int
    public let name: String
    public let nameOrig: String
    public let workType: String
    public let workTypeId: Int
    public let workTypeKey: String
    public let imageURL: URL?
    public let year: Int
    public let authors: [String]
    public let rating: Float
    public let votes: Int
    public let reviewsCount: Int

    public init(id: Int,
                name: String,
                nameOrig: String,
                workType: String,
                workTypeId: Int,
                workTypeKey: String,
                imageURL: URL?,
                year: Int,
                authors: [String],
                rating: Float,
                votes: Int,
                reviewsCount: Int) {

        self.id = id
        self.name = name
        self.nameOrig = nameOrig
        self.workType = workType
        self.workTypeId = workTypeId
        self.workTypeKey = workTypeKey
        self.imageURL = imageURL
        self.year = year
        self.authors = authors
        self.rating = rating
        self.votes = votes
        self.reviewsCount = reviewsCount
    }
}
