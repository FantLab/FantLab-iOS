import Foundation

public final class WorkModel {
    public final class AuthorModel {
        public let id: Int
        public let name: String
        public let type: String
        public let isOpened: Bool

        public init(id: Int,
                    name: String,
                    type: String,
                    isOpened: Bool) {

            self.id = id
            self.name = name
            self.type = type
            self.isOpened = isOpened
        }
    }

    public let id: Int
    public let name: String
    public let origName: String
    public let year: Int
    public let imageURL: URL?
    public let workType: String
    public let publishStatuses: [String]
    public let rating: Float
    public let votes: Int
    public let reviewsCount: Int
    public let authors: [AuthorModel]
    public let descriptionText: String
    public let descriptionAuthor: String
    public let notes: String

    public init(id: Int,
                name: String,
                origName: String,
                year: Int,
                imageURL: URL?,
                workType: String,
                publishStatuses: [String],
                rating: Float,
                votes: Int,
                reviewsCount: Int,
                authors: [AuthorModel],
                descriptionText: String,
                descriptionAuthor: String,
                notes: String) {

        self.id = id
        self.name = name
        self.origName = origName
        self.year = year
        self.imageURL = imageURL
        self.workType = workType
        self.publishStatuses = publishStatuses
        self.rating = rating
        self.votes = votes
        self.reviewsCount = reviewsCount
        self.authors = authors
        self.descriptionText = descriptionText
        self.descriptionAuthor = descriptionAuthor
        self.notes = notes
    }
}
