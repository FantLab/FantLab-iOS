import Foundation
import FLKit

public final class WorkModel: ObjectPropertiesProvider {
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

    public final class ParentWorkModel {
        public let id: Int
        public let name: String
        public let workType: String

        public init(id: Int,
                    name: String,
                    workType: String) {

            self.id = id
            self.name = name
            self.workType = workType
        }
    }

    public final class GenreGroupModel {
        public final class GenreModel {
            public let id: Int
            public let label: String
            public let votes: Int
            public let percent: Float
            public let genres: [GenreModel]

            public init(id: Int,
                        label: String,
                        votes: Int,
                        percent: Float,
                        genres: [GenreModel]) {

                self.id = id
                self.label = label
                self.votes = votes
                self.percent = percent
                self.genres = genres
            }
        }

        public let title: String
        public let genres: [GenreModel]

        public init(title: String, genres: [GenreModel]) {
            self.title = title
            self.genres = genres
        }
    }

    public let id: Int
    public let name: String
    public let origName: String
    public let year: Int
    public let workType: String
    public let workTypeKey: String
    public let publishStatuses: [String]
    public let rating: Float
    public let votes: Int
    public let reviewsCount: Int
    public let descriptionText: String
    public let descriptionAuthor: String
    public let notes: String
    public let authors: [AuthorModel]
    public let children: ChildWorkList
    public let parents: [[ParentWorkModel]]
    public let classificatory: [GenreGroupModel]
    public let awards: [AwardPreviewModel]
    public let editionBlocks: [EditionBlockModel]

    public init(id: Int,
                name: String,
                origName: String,
                year: Int,
                workType: String,
                workTypeKey: String,
                publishStatuses: [String],
                rating: Float,
                votes: Int,
                reviewsCount: Int,
                descriptionText: String,
                descriptionAuthor: String,
                notes: String,
                authors: [AuthorModel],
                children: ChildWorkList,
                parents: [[ParentWorkModel]],
                classificatory: [GenreGroupModel],
                awards: [AwardPreviewModel],
                editionBlocks: [EditionBlockModel]) {

        self.id = id
        self.name = name
        self.origName = origName
        self.year = year
        self.workType = workType
        self.workTypeKey = workTypeKey
        self.publishStatuses = publishStatuses
        self.rating = rating
        self.votes = votes
        self.reviewsCount = reviewsCount
        self.descriptionText = descriptionText
        self.descriptionAuthor = descriptionAuthor
        self.notes = notes
        self.authors = authors
        self.children = children
        self.parents = parents
        self.classificatory = classificatory
        self.awards = awards
        self.editionBlocks = editionBlocks
    }

    // MARK: -

    public var objectProperties: [ObjectProperty] {
        return classificatory.map({ genreGroup -> ObjectProperty in
            return (genreGroup.title, genreGroup.genres.map({ $0.label }).prefix(2).joined(separator: "\n"))
        })
    }
}
