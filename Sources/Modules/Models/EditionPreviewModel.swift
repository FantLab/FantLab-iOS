import Foundation

public final class EditionBlockModel {
    public let type: String
    public let title: String
    public let list: [EditionPreviewModel]

    public init(type: String,
                title: String,
                list: [EditionPreviewModel]) {

        self.type = type
        self.title = title
        self.list = list
    }
}

public final class EditionPreviewModel {
    public let id: Int
    public let langCode: String
    public let year: Int
    public let coverURL: URL?
    public let correctLevel: Float

    public init(id: Int,
                langCode: String,
                year: Int,
                coverURL: URL?,
                correctLevel: Float) {

        self.id = id
        self.langCode = langCode
        self.year = year
        self.coverURL = coverURL
        self.correctLevel = correctLevel
    }
}
