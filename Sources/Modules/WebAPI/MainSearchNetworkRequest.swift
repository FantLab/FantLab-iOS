import Foundation
import FantLabUtils
import FantLabModels

public final class MainSearchNetworkRequest: NetworkRequest {
    public typealias ModelType = SearchResultsModel

    private let searchText: String

    public init(searchText: String) {
        self.searchText = searchText
    }

    public func makeURLRequest() -> URLRequest {
        let text = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        return URLRequest(url: URL(string: "https://\(Hosts.api)/search-txt?q=\(text)")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> SearchResultsModel {
        guard let json = JSON(jsonData: data) else {
            throw NetworkError.invalidJSON
        }

        let works = json.works.array.map {
            SearchResultsModel.WorkModel(
                id: $0.id.intValue,
                name: $0.name.stringValue.nilIfEmpty ?? $0.name_orig.stringValue
            )
        }

        return SearchResultsModel(works: works)
    }
}
