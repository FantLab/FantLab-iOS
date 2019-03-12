import Foundation
import FLKit
import FLModels

public final class GetUserReviewsNetworkRequest: NetworkRequest {
    public typealias ModelType = [WorkReviewModel]

    private let userId: Int
    private let page: Int
    private let sort: ReviewsSort

    public init(userId: Int, page: Int, sort: ReviewsSort) {
        self.userId = userId
        self.page = page
        self.sort = sort
    }

    public func makeURLRequest() -> URLRequest {
        return URLRequest(url: URL(string: "https://\(Hosts.api)/user/\(userId)/responses?sort=\(sort.rawValue)&page=\(page)")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> [WorkReviewModel] {
        let json = try DynamicJSON(jsonData: data)

        return JSONConverter.makeWorkReviewsFrom(json: json)
    }
}
