import Foundation
import RxSwift

public enum NetworkError: Error, ErrorHumanReadableTextConvertible {
    case unknown

    public var humanReadableDescription: String {
        switch self {
        case .unknown:
            return "Неизвестная сетевая ошибка"
        }
    }
}

public protocol NetworkRequest {
    associatedtype ModelType

    func makeURLRequest() -> URLRequest
    func parse(response: URLResponse, data: Data) throws -> ModelType
}

public final class NetworkClient {
    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

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
