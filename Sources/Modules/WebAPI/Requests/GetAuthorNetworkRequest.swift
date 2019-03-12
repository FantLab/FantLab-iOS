import Foundation
import FLKit
import FLModels

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
        let json = try DynamicJSON(jsonData: data)

        let author = JSONConverter.makeAuthorModelFrom(json: json)

        if author.id == 0 || !author.isOpened {
            throw WebAPIError.notFound
        }

        return author
    }
}
