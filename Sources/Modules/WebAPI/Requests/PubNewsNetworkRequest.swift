import Foundation
import FLKit
import FLModels

public final class PubNewsNetworkRequest: NetworkRequest {
    public typealias ModelType = [PubNewsModel]
    
    private let requestType: PubNewsType
    private let lang: PubNewsLang
    private let sort: PubNewsSort
    private let page: Int
    
    public init(requestType: PubNewsType,
                lang: PubNewsLang,
                sort: PubNewsSort,
                page: Int) {
        
        self.requestType = requestType
        self.lang = lang
        self.sort = sort
        self.page = page
    }
    
    public func makeURLRequest() -> URLRequest {
        return URLRequest(url: URL(string: "https://\(Hosts.api)/\(requestType.rawValue)?lang=\(lang.rawValue)&sort=\(sort.rawValue)&page=\(page)")!)
    }
    
    public func parse(response: URLResponse, data: Data) throws -> [PubNewsModel] {
        let json = try DynamicJSON(jsonData: data)
        
        return JSONConverter.makePubNewsFrom(json: json)
    }
}
