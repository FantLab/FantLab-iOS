import Foundation
import FantLabUtils
import FantLabModels

public final class ISBNEditionNetworkRequest: NetworkRequest {
    public typealias ModelType = Int

    private let isbn: String

    public init(isbn: String) {
        self.isbn = isbn
    }

    public func makeURLRequest() -> URLRequest {
        let isbnText = isbn.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""

        return URLRequest(url: URL(string: "https://\(Hosts.api)/search-editions?q=\(isbnText)&page=1&onlymatches=1")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> Int {
        let json = try JSON(jsonData: data)

        let editionId = json[0].edition_id.intValue

        if editionId == 0 {
            throw WebAPIError.notFound
        }

        return editionId
    }
}
