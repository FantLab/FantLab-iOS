import Foundation
import FantLabUtils
import FantLabModels

public struct MainSearchResult {
    public let searchText: String
    public let works: [WorkPreviewModel]
    public let authors: [AuthorPreviewModel]
}

public final class MainSearchNetworkRequest: NetworkRequest {
    public typealias ModelType = MainSearchResult

    private let searchText: String

    public init(searchText: String) {
        self.searchText = searchText
    }

    public func makeURLRequest() -> URLRequest {
        let text = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        return URLRequest(url: URL(string: "https://\(Hosts.api)/search-txt?q=\(text)")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> MainSearchResult {
        let json = try JSON(jsonData: data)

        let works = JSONConverter.makeWorkPreviewsFrom(json: json.works)
        let authors = JSONConverter.makeAuthorPreviewsFrom(json: json.authors)

        if works.isEmpty && authors.isEmpty {
            throw WebAPIError.notFound
        }

        return MainSearchResult(searchText: searchText, works: works, authors: authors)
    }
}
