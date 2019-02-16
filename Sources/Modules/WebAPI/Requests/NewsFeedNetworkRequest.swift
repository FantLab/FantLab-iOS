import Foundation
import FantLabUtils
import FantLabModels

public final class NewsFeedNetworkRequest: NetworkRequest {
    public typealias ModelType = [NewsModel]

    public init() {}

    public func makeURLRequest() -> URLRequest {
        return URLRequest(url: URL(string: "https://fantlab.ru/news.rss")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> [NewsModel] {
        let rss = try RSSParser(data: data)
        
        return rss.news
    }
}
