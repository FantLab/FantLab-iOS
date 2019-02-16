import Foundation

public final class NewsModel {
    public let title: String
    public let text: String
    public let date: Date
    public let url: URL

    public init(title: String,
                text: String,
                date: Date,
                url: URL) {

        self.title = title
        self.text = text
        self.date = date
        self.url = url
    }
}
