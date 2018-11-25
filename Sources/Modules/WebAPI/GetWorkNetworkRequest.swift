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

        return WorkModel(
            id: json["work_id"].intValue,
            name: json["work_name"].stringValue,
            origName: json["work_name_orig"].stringValue,
            year: json["work_year"].intValue,
            imageURL: URL.from(string: json["image"].stringValue),
            workType: json["work_type"].stringValue,
            publishStatuses: json["publish_statuses"].jsonArray.map({ $0.stringValue }),
            rating: json["rating"]["rating"].floatValue,
            votes: json["rating"]["voters"].intValue,
            reviewsCount: json["val_responsecount"].intValue,
            authors: json["authors"].jsonArray.map({
                WorkModel.AuthorModel(
                    id: $0["id"].intValue,
                    name: $0["name"].stringValue,
                    type: $0["type"].stringValue,
                    isOpened: $0["is_opened"].boolValue
                )
            }),
            descriptionText: json["work_description"].stringValue,
            descriptionAuthor: json["work_description_author"].stringValue,
            notes: json["work_notes"].stringValue
        )
    }
}
