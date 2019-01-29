import Foundation

public final class EditionModel {
    public let id: Int
    public let name: String
    public let image: URL?
    public let correctLevel: Float
    public let year: Int
    public let planDate: String
    public let type: String
    public let copies: Int
    public let pages: Int
    public let coverType: String
    public let publisher: String
    public let format: String
    public let isbn: String
    public let lang: String
    public let content: [String]
    public let description: String
    public let notes: String
    public let planDescription: String

    public init(id: Int,
                name: String,
                image: URL?,
                correctLevel: Float,
                year: Int,
                planDate: String,
                type: String,
                copies: Int,
                pages: Int,
                coverType: String,
                publisher: String,
                format: String,
                isbn: String,
                lang: String,
                content: [String],
                description: String,
                notes: String,
                planDescription: String) {

        self.id = id
        self.name = name
        self.image = image
        self.correctLevel = correctLevel
        self.year = year
        self.planDate = planDate
        self.type = type
        self.copies = copies
        self.pages = pages
        self.coverType = coverType
        self.publisher = publisher
        self.format = format
        self.isbn = isbn
        self.lang = lang
        self.content = content
        self.description = description
        self.notes = notes
        self.planDescription = planDescription
    }
}
