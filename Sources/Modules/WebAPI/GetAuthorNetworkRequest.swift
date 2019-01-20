import Foundation
import FantLabUtils
import FantLabModels

public final class GetAuthorNetworkRequest: NetworkRequest {
    public typealias ModelType = AuthorModel

    private let authorId: Int

    public init(authorId: Int) {
        self.authorId = authorId
    }

    public func makeURLRequest() -> URLRequest {
        return URLRequest(url: URL(string: "https://\(Hosts.api)/autor/\(authorId)/extended")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> AuthorModel {
        guard let json = JSON(jsonData: data) else {
            throw NetworkError.invalidJSON
        }

        return JSONConverter.makeAuthorModelFrom(json: json)
    }
}
