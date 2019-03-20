import Foundation
import UIKit
import ALLKit
import RxSwift
import YYWebImage
import FLKit
import FLStyle
import FLText
import FLUIKit
import FLLayoutSpecs
import FLContentBuilders

final class TextListViewController: ListViewController<DataStateContentBuilder<TextListContentBuilder>>, TextListContentBuilderDelegate {
    private let textSubject = PublishSubject<FLText>()
    private let hiddenTextSubject = PublishSubject<Int>()
    private let imageSubject = PublishSubject<(Int, UIImage?)>()
    private let originalString: String
    private let headerListItems: [ListItem]
    private let makeURLFromPhotoIndex: ((Int) -> URL)?

    init(string: String, customHeaderListItems: [ListItem], makePhotoURL: ((Int) -> URL)?) {
        originalString = string
        headerListItems = customHeaderListItems
        makeURLFromPhotoIndex = makePhotoURL

        super.init(contentBuilder: DataStateContentBuilder(dataContentBuilder: TextListContentBuilder()))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    deinit {
        textSubject.onCompleted()
        hiddenTextSubject.onCompleted()
        imageSubject.onCompleted()
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        contentBuilder.dataContentBuilder.delegate = self

        setupStateMapping()

        apply(viewState: .loading)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.setupText()
        }
    }

    // MARK: -

    private func setupStateMapping() {
        let hiddenTextObservable = hiddenTextSubject.scan(into: Set<Int>()) {
            $0.insert($1)
        }

        let imagesObservable = imageSubject.scan(into: Dictionary<Int, UIImage>()) {
            $0[$1.0] = $1.1
        }

        Observable.combineLatest(textSubject, hiddenTextObservable, imagesObservable, Observable.just(headerListItems))
            .map({ (text, spoilers, images, headerItems) -> TextListViewState in
                TextListViewState(
                    text: text,
                    expandedTextIndices: spoilers,
                    images: images,
                    customHeaderItems: headerItems
                )
            })
            .subscribe(onNext: { [weak self] viewState in
                self?.apply(viewState: .success(viewState))
            })
            .disposed(by: disposeBag)
    }

    private func setupText() {
        let text = FLText(
            string: originalString,
            decorator: TextStyle.defaultTextDecorator,
            setupLinkAttribute: true
        )

        textSubject.onNext(text)
        hiddenTextSubject.onNext(-1)
        imageSubject.onNext((-1, nil))
    }

    // MARK: - TextListContentBuilderDelegate

    func makeURLFrom(photoIndex: Int) -> URL? {
        return makeURLFromPhotoIndex?(photoIndex)
    }

    func open(url: URL) {
        AppRouter.shared.openURL(url)
    }

    func showHiddenText(index: Int) {
        hiddenTextSubject.onNext(index)
    }

    func save(image: UIImage, at index: Int) {
        imageSubject.onNext((index, image))
    }
}
