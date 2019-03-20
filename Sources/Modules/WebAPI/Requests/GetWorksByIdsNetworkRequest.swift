import Foundation
import FLKit
import FLModels

public final class GetWorksByIdsNetworkRequest: NetworkRequest {
    public typealias ModelType = [WorkPreviewModel]

    private let idIndexTable: [Int: Int]

    public init(workIds: [Int]) {
        self.idIndexTable = workIds.enumerated().reduce(into: [Int: Int](), { (table, args) in
            table[args.element] = args.offset
        })
    }

    public func makeURLRequest() -> URLRequest {
        let idString = idIndexTable.keys.map({ String($0) }).joined(separator: ",")

        return URLRequest(url: URL(string: "https://\(Hosts.api)/search-ids?w=\(idString)")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> [WorkPreviewModel] {
        let json = try DynamicJSON(jsonData: data)

        let works = JSONConverter.makeWorkPreviewsFrom(json: json.works)

        return works.sorted { (w1, w2) -> Bool in
            guard let i1 = idIndexTable[w1.id], let i2 = idIndexTable[w2.id] else {
                return false
            }

            return i1 < i2
        }
    }
}
