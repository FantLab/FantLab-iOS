import Foundation
import RxSwift

public enum NetworkError: Error {
    case invalidJSON
    case incompleteJSON
    case unknown
}

public protocol NetworkRequest {
    associatedtype ModelType

    func makeURLRequest() -> URLRequest
    func parse(response: URLResponse, data: Data) throws -> ModelType
}

public final class NetworkClient {
    public static let shared = NetworkClient()

    private let session = URLSession.shared

    public func perform<RequestType: NetworkRequest>(request: RequestType) -> Observable<RequestType.ModelType> {
        return Observable<(Data, URLResponse)>.create({ [session] observer -> Disposable in
            let task = session.dataTask(with: request.makeURLRequest(), completionHandler: { (data, response, error) in
                if let data = data, let response = response {
                    observer.onNext((data, response))
                    observer.onCompleted()
                } else {
                    observer.onError(error ?? NetworkError.unknown)
                }
            })

            task.resume()

            return Disposables.create(with: task.cancel)
        }).map({ (data, response) -> RequestType.ModelType in
            return try autoreleasepool {
                try request.parse(response: response, data: data)
            }
        })
    }
}
