import Foundation
import FLKit
import FLModels

public final class FreshReviewsNetworkRequest: NetworkRequest {
    public typealias ModelType = [WorkReviewModel]

    private let page: Int

    public init(page: Int) {
        self.page = page
    }

    public func makeURLRequest() -> URLRequest {
        return URLRequest(url: URL(string: "https://\(Hosts.api)/responses?page=\(page)")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> [WorkReviewModel] {
        let json = try DynamicJSON(jsonData: data)

        return JSONConverter.makeWorkReviewsFrom(json: json)
    }
}
