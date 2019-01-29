import Foundation
import FantLabUtils
import FantLabModels

public final class GetEditionNetworkRequest: NetworkRequest {
    public typealias ModelType = EditionModel

    private let editionId: Int

    public init(editionId: Int) {
        self.editionId = editionId
    }

    public func makeURLRequest() -> URLRequest {
        return URLRequest(url: URL(string: "https://\(Hosts.api)/edition/\(editionId)/extended")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> EditionModel {
        guard let json = JSON(jsonData: data) else {
            throw NetworkError.invalidJSON
        }

        return JSONConverter.makeEditionFrom(json: json)
    }
}
