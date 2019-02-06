import Foundation

public final class EditionModel {
    public final class ImageModel {
        public let url: URL?
        public let urlOrig: URL?
        public let text: String

        public init(url: URL?,
                    urlOrig: URL?,
                    text: String) {

            self.url = url
            self.urlOrig = urlOrig
            self.text = text
        }
    }

    public let id: Int
    public let name: String
    public let image: URL?
    public let coverHDURL: URL?
    public let images: [ImageModel]
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
                coverHDURL: URL?,
                images: [ImageModel],
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
        self.coverHDURL = coverHDURL
        self.images = images
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

extension EditionModel {
    public var biggestImageURL: URL? {
        return coverHDURL ?? image
    }
}
