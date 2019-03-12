import Foundation
import FLKit
import FLModels

public final class GetUserProfileNetworkRequest: NetworkRequest {
    public typealias ModelType = UserProfileModel

    private let userId: Int

    public init(userId: Int) {
        self.userId = userId
    }

    public func makeURLRequest() -> URLRequest {
        return URLRequest(url: URL(string: "https://\(Hosts.api)/user/\(userId)")!)
    }

    public func parse(response: URLResponse, data: Data) throws -> UserProfileModel {
        let json = try DynamicJSON(jsonData: data)

        let user = JSONConverter.makeUserProfileFrom(json: json)

        if user.id == 0 {
            throw WebAPIError.notFound
        }

        return user
    }
}
