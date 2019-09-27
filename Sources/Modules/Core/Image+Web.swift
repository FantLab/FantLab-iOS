import Foundation
import Nuke
import RxSwift

public enum WebImage {
    public static func load(url: URL?, into imageView: UIImageView, placeholder: UIImage? = nil) {
        url.flatMap {
            _ = Nuke.loadImage(
                with: $0,
                options: ImageLoadingOptions(
                    placeholder: placeholder,
                    transition: .fadeIn(duration: 0.33)
                ),
                into: imageView
            )
        }
    }

    public static func load(url: URL) -> Observable<UIImage> {
        return Observable.create { o in
            let task = ImagePipeline.shared.loadImage(with: url, progress: nil) { result in
                switch result {
                case let .success(response):
                    o.onNext(response.image)
                    o.onCompleted()
                case let .failure(error):
                    o.onError(error)
                }
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }
}
