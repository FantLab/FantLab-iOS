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
            descriptionText: json["work_description"].stringValue,
            descriptionAuthor: json["work_description_author"].stringValue,
            notes: json["work_notes"].stringValue,
            linguisticAnalysis: json["la_resume"].jsonArray.map({ $0.stringValue }),
            authors: json["authors"].jsonArray.map({
                WorkModel.AuthorModel(
                    id: $0["id"].intValue,
                    name: $0["name"].stringValue,
                    type: $0["type"].stringValue,
                    isOpened: $0["is_opened"].boolValue
                )
            }),
            children: json["children"].jsonArray.map({
                WorkModel.ChildWorkModel(
                    id: $0["work_id"].intValue,
                    name: $0["work_name"].stringValue,
                    origName: $0["work_name_orig"].stringValue,
                    nameBonus: $0["work_name_bonus"].stringValue,
                    rating: $0["val_midmark_by_weight"].floatValue,
                    votes: $0["val_voters"].intValue,
                    workType: $0["work_type"].stringValue,
                    publishStatus: $0["publish_status"].stringValue,
                    isPublished: $0["work_published"].boolValue,
                    year: $0["work_year"].intValue,
                    deepLevel: $0["deep"].intValue,
                    plus: $0["plus"].boolValue
                )
            }),
            parents: json["parents"]["cycles"].jsonArray.map({
                $0.jsonArray.map({
                    WorkModel.ParentWorkModel(
                        id: $0["work_id"].intValue,
                        name: $0["work_name"].stringValue,
                        workType: $0["work_type"].stringValue
                    )
                })
            }),
            classificatory: json["classificatory"]["genre_group"].jsonArray.map({
                WorkModel.GenreGroupModel(
                    title: $0["label"].stringValue,
                    genres: $0["genre"].jsonArray.map({
                        parseGenre(json: $0)
                    })
                )
            })
        )
    }

    private func parseGenre(json: JSON) -> WorkModel.GenreGroupModel.GenreModel {
        return WorkModel.GenreGroupModel.GenreModel(
            id: json["genre_id"].intValue,
            label: json["label"].stringValue,
            votes: json["votes"].intValue,
            percent: json["percent"].floatValue,
            genres: json["genre"].jsonArray.map({
                parseGenre(json: $0)
            })
        )
    }
}
