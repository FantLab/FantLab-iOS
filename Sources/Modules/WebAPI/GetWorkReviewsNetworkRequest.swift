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

        return json["items"].jsonArray.map {
            WorkReviewModel(
                id: $0["response_id"].intValue,
                date: Date.from(string: $0["response_date"].stringValue, format: "yyyy-MM-dd HH:mm:ss"),
                text: $0["response_text"].stringValue,
                votes: $0["response_votes"].intValue,
                mark: $0["mark"].intValue,
                user: WorkReviewModel.UserModel(
                    id: $0["user_id"].intValue,
                    name: $0["user_name"].stringValue,
                    avatar: URL.from(string: $0["user_avatar"].stringValue)
                )
            )
        }
    }
}
