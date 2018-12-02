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

    public final class ChildWorkModel {
        public let id: Int
        public let name: String
        public let origName: String
        public let nameBonus: String
        public let rating: Float
        public let votes: Int
        public let workType: String
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
            self.publishStatus = publishStatus
            self.isPublished = isPublished
            self.year = year
            self.deepLevel = deepLevel
            self.plus = plus
        }
    }

    public final class GenreGroupModel {
        public let title: String
        public let genres: [String]

        public init(title: String, genres: [String]) {
            self.title = title
            self.genres = genres
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
    public let descriptionText: String
    public let descriptionAuthor: String
    public let notes: String
    public let authors: [AuthorModel]
    public let children: [ChildWorkModel]
    public let classificatory: [GenreGroupModel]

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
                descriptionText: String,
                descriptionAuthor: String,
                notes: String,
                authors: [AuthorModel],
                children: [ChildWorkModel],
                classificatory: [GenreGroupModel]) {

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
        self.descriptionText = descriptionText
        self.descriptionAuthor = descriptionAuthor
        self.notes = notes
        self.authors = authors
        self.children = children
        self.classificatory = classificatory
    }
}
