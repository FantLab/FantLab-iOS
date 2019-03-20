import Foundation
import FLKit
import FLModels

public final class MainSearchNetworkRequest: NetworkRequest {
    public typealias ModelType = SearchResultModel

    private let searchText: String

    public init(searchText: String) {
        self.searchText = searchText
    }

    public func makeURLRequest() -> URLRequest {
        let text = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        return URLRequest(url: URL(string: "https://\(Hosts.api)/search-txt?q=\(text)")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> SearchResultModel {
        let json = try DynamicJSON(jsonData: data)

        let works = JSONConverter.makeWorkPreviewsFrom(json: json.works)
        let authors = JSONConverter.makeAuthorPreviewsFrom(json: json.authors)

        return SearchResultModel(authors: authors, works: works, searchText: searchText)
    }
}
