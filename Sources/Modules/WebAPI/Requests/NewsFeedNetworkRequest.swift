import Foundation
import FLKit
import FLModels

public final class NewsFeedNetworkRequest: NetworkRequest {
    public typealias ModelType = [NewsModel]

    private let page: Int

    public init(page: Int) {
        self.page = page
    }

    public func makeURLRequest() -> URLRequest {
        return URLRequest(url: URL(string: "https://\(Hosts.api)/news?page=\(page)")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> [NewsModel] {
        let json = try DynamicJSON(jsonData: data)

        let news = JSONConverter.makeNewsFrom(json: json)
        
        return news
    }
}
