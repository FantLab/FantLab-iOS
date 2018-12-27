import Foundation
import UIKit
import ALLKit
import RxSwift
import YYWebImage
import FantLabUtils
import FantLabStyle
import FantLabText
import FantLabSharedUI

final class TextListViewController: ListViewController {
    private static let textDecorator: TextDecorator = {
        let defaultParagraphStyle = NSMutableParagraphStyle()
        defaultParagraphStyle.alignment = .left
        defaultParagraphStyle.lineSpacing = 4
        defaultParagraphStyle.paragraphSpacing = 4
        defaultParagraphStyle.paragraphSpacingBefore = 4

        let quoteParagraphStyle = NSMutableParagraphStyle()
        quoteParagraphStyle.alignment = .left
        quoteParagraphStyle.lineSpacing = 4
        quoteParagraphStyle.paragraphSpacing = 4
        quoteParagraphStyle.paragraphSpacingBefore = 4

        return TextDecorator(
            defaultAttributes: [
                .font: Fonts.system.regular(size: 16),
                .foregroundColor: UIColor.black,
                .paragraphStyle: defaultParagraphStyle
            ],
            quoteAttributes: [
                .font: Fonts.system.italic(size: 15),
                .foregroundColor: UIColor.gray,
                .paragraphStyle: quoteParagraphStyle
            ],
            linkAttributes: [
                .foregroundColor: Colors.flOrange,
                .underlineStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)
            ],
            boldFont: Fonts.system.bold(size: 16),
            italicFont: Fonts.system.italic(size: 16)
        )
    }()

    private let originalString: String
    private let headerListItems: [ListItem]
    private let router: TextUIModuleRouter
    private let textSubject = PublishSubject<FLText>()
    private let hiddenTextSubject = PublishSubject<Int>()
    private let imageSubject = PublishSubject<(Int, UIImage?)>()

    init(string: String,
         customHeaderListItems: [ListItem],
         router: TextUIModuleRouter) {

        originalString = string
        headerListItems = customHeaderListItems

        self.router = router

        super.init(nibName: nil, bundle: nil)
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

        let hiddenTextObservable = hiddenTextSubject.scan(into: Set<Int>()) {
            $0.insert($1)
        }

        let imagesObservable = imageSubject.scan(into: Dictionary<Int, UIImage>()) {
            $0[$1.0] = $1.1
        }

        Observable.combineLatest(textSubject, hiddenTextObservable, imagesObservable)
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ [weak self] (text, expandedTextIndices, images) -> [ListItem] in
                return self?.makeListItemsFrom(
                    text: text,
                    expandedTextIndices: expandedTextIndices,
                    images: images
                    ) ?? []
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.adapter.set(items: items)
            })
            .disposed(by: disposeBag)

        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }

            let text = FLText(
                string: strongSelf.originalString,
                decorator: TextListViewController.textDecorator,
                setupLinkAttribute: true
            )

            strongSelf.textSubject.onNext(text)
            strongSelf.hiddenTextSubject.onNext(-1)
            strongSelf.imageSubject.onNext((-1, nil))
        }
    }

    private func makeListItemsFrom(text: FLText,
                                   expandedTextIndices: Set<Int>,
                                   images: Dictionary<Int, UIImage>) -> [ListItem] {
        var items: [ListItem] = headerListItems

        items.append(ListItem(
            id: "header_space",
            layoutSpec: EmptySpaceLayoutSpec(model: (UIColor.white, 16))
        ))

        text.items.enumerated().forEach { (index, item) in
            let itemId = String(index)

            switch item {
            case let .string(string):
                let item = ListItem(
                    id: itemId,
                    layoutSpec: StringLayoutSpec(
                        model: StringLayoutModel(
                            string: string,
                            linkAttributes: text.decorator.linkAttributes,
                            openURL: ({ [weak self] url in
                                self?.router.open(url: url)
                            })
                        )
                    )
                )

                items.append(item)
            case let .hidden(string: string, name: name):
                if expandedTextIndices.contains(index) {
                    let item = ListItem(
                        id: itemId + "_expanded",
                        layoutSpec: ExpandedHiddenStringLayoutSpec(model: (string, name))
                    )

                    items.append(item)
                } else {
                    let item = ListItem(
                        id: itemId + "_collapsed",
                        layoutSpec: CollapsedHiddenStringLayoutSpec(model: name)
                    )

                    item.didSelect = { [weak self] cell in
                        CellSelection.scale(cell: cell, action: {
                            self?.hiddenTextSubject.onNext(index)
                        })
                    }

                    items.append(item)
                }
            case let .quote(string):
                let item = ListItem(
                    id: itemId,
                    layoutSpec: QuoteLayoutSpec(model: string)
                )

                items.append(item)
            case let .image(url):
                if let image = images[index] {
                    let item = ListItem(
                        id: itemId + "_image",
                        layoutSpec: ImageLayoutSpec(model: image)
                    )

                    items.append(item)
                } else {
                    let item = ListItem(
                        id: itemId + "_loading",
                        layoutSpec: ImageLoadingLayoutSpec(model: (url, { [weak self] image in
                            self?.imageSubject.onNext((index, image))
                        }))
                    )

                    items.append(item)
                }
            case let .video(url):
                print(url)

                // TODO:

                break
            }

            items.append(ListItem(
                id: itemId + "_separator",
                layoutSpec: EmptySpaceLayoutSpec(model: (UIColor.white, 24))
            ))
        }

        return items
    }
}
