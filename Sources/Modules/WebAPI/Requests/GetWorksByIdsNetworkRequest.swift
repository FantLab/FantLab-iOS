import Foundation
import FLKit
import FLModels

public final class GetWorksByIdsNetworkRequest: NetworkRequest {
    public typealias ModelType = [WorkPreviewModel]

    private let workIds: [Int]

    public init(workIds: [Int]) {
        self.workIds = workIds
    }

    public func makeURLRequest() -> URLRequest {
        let idString = workIds.map({ String($0) }).joined(separator: ",")

        return URLRequest(url: URL(string: "https://\(Hosts.api)/search-ids?w=\(idString)")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> [WorkPreviewModel] {
        let json = try DynamicJSON(jsonData: data)

        return JSONConverter.makeWorkPreviewsFrom(json: json.works)
    }
}
