import Foundation
import FantLabUtils
import FantLabModels

public final class MainSearchNetworkRequest: NetworkRequest {
    public typealias ModelType = [WorkPreviewModel]

    private let searchText: String

    public init(searchText: String) {
        self.searchText = searchText
    }

    public func makeURLRequest() -> URLRequest {
        let text = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        return URLRequest(url: URL(string: "https://\(Hosts.api)/search-txt?q=\(text)")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> [WorkPreviewModel] {
        guard let json = JSON(jsonData: data) else {
            throw NetworkError.invalidJSON
        }

        return JSONConverter.makeWorkPreviewsFrom(json: json.works)
    }
}
