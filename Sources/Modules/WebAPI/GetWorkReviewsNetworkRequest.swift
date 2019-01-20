import Foundation
import FantLabUtils
import FantLabModels

public final class GetWorkReviewsNetworkRequest: NetworkRequest {
    public typealias ModelType = [WorkReviewModel]

    private let workId: Int
    private let page: Int
    private let sort: ReviewsSort

    public init(workId: Int, page: Int, sort: ReviewsSort) {
        self.workId = workId
        self.page = page
        self.sort = sort
    }

    public func makeURLRequest() -> URLRequest {
        return URLRequest(url: URL(string: "https://\(Hosts.api)/work/\(workId)/responses?sort=\(sort.rawValue)&page=\(page)")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> [WorkReviewModel] {
        guard let json = JSON(jsonData: data) else {
            throw NetworkError.invalidJSON
        }

        return JSONConverter.makeWorkReviewsFrom(json: json)
    }
}
