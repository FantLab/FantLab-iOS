import Foundation
import FantLabUtils
import FantLabModels

public final class GetWorkNetworkRequest: NetworkRequest {
    public typealias ModelType = WorkModel

    private let workId: Int

    public init(workId: Int) {
        self.workId = workId
    }

    public func makeURLRequest() -> URLRequest {
        return URLRequest(url: URL(string: "https://\(Hosts.api)/work/\(workId)/extended")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> WorkModel {
        guard let json = JSON(jsonData: data) else {
            throw NetworkError.invalidJSON
        }

        return JSONConverter.makeWorkModelFrom(json: json)
    }
}
