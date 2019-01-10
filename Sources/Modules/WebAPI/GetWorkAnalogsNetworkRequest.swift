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
        return URLRequest(url: URL(string: "https://\(Hosts.api)/work/\(workId)/similars")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> [WorkAnalogModel] {
        guard let json = JSON(jsonData: data) else {
            throw NetworkError.invalidJSON
        }

        return json.array.map {
            return WorkAnalogModel(
                id: $0.id.intValue,
                name: $0.name.stringValue,
                nameOrig: $0.name_orig.stringValue,
                workType: $0.name_type.stringValue,
                imageURL: URL.from(string: $0.image.stringValue),
                year: $0.year.intValue,
                authors: $0.creators.authors.array.map({
                    $0.name.string ?? $0.name_orig.stringValue
                }),
                rating: $0.stat.rating.floatValue,
                votes: $0.stat.voters.intValue,
                reviewsCount: $0.stat.responses.intValue
            )
        }
    }
}
