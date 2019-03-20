import Foundation

public final class NewsModel {
    public let id: Int
    public let title: String
    public let text: String
    public let image: URL?
    public let date: Date
    public let category: String

    public init(id: Int,
                title: String,
                text: String,
                image: URL?,
                date: Date,
                category: String) {

        self.id = id
        self.title = title
        self.text = text
        self.image = image
        self.date = date
        self.category = category
    }
}
