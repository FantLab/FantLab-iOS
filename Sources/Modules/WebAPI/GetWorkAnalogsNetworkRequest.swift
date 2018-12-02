import Foundation
import FantLabUtils
import FantLabModels

public final class GetWorkAnalogsNetworkRequest: NetworkRequest {
    public typealias ModelType = [WorkAnalogModel]

    private let workId: Int

    public init(workId: Int) {
        self.workId = workId
    }

    public func makeURLRequest() -> URLRequest {
        return URLRequest(url: URL(string: "https://\(Hosts.api)/work/\(workId)/analogs")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> [WorkAnalogModel] {
        guard let json = JSON(jsonData: data) else {
            throw NetworkError.invalidJSON
        }

        return json.jsonArray.map {
            WorkAnalogModel(
                id: $0["work_id"].intValue,
                name: $0["rusname"].stringValue,
                nameOrig: $0["name"].stringValue,
                workType: $0["name_show_im"].stringValue,
                year: $0["year"].intValue,
                authors: [$0["autor1_rusname"].string ?? $0["autor1_name"].stringValue]
            )
        }
    }
}
