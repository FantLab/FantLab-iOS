import Foundation
import UIKit
import ALLKit
import FLModels
import FLStyle

private final class EditionListView: UIView {
    private let adapter = CollectionViewAdapter(
        scrollDirection: .horizontal,
        sectionInset: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8),
        minimumLineSpacing: 0,
        minimumInteritemSpacing: 0
    )

    override init(frame: CGRect) {
        super.init(frame: frame)

        adapter.collectionView.backgroundColor = UIColor.white
        adapter.collectionView.alwaysBounceHorizontal = true
        adapter.collectionView.showsHorizontalScrollIndicator = false

        addSubview(adapter.collectionView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard !bounds.isEmpty else {
            return
        }

        adapter.collectionView.frame = bounds

        adapter.set(sizeConstraints: SizeConstraints(width: bounds.height * 0.7, height: bounds.height))
    }

    var openEdition: ((Int) -> Void)?

    func set(editions: [EditionPreviewModel]) {
        DispatchQueue.global().async { [weak self] in
            let items: [ListItem] = editions.enumerated().map({ (index, edition) in
                let item = ListItem(
                    id: String(index),
                    layoutSpec: EditionPreviewLayoutSpec(model: edition)
                )

                item.didTap = { (view, _) in
                    view.animated(action: { [weak self] in
                        self?.openEdition?(edition.id)
                    })
                }

                return item
            })

            DispatchQueue.main.async {
                self?.adapter.set(items: items)
            }
        }
    }
}

public final class EditionListLayoutSpec: ModelLayoutSpec<([EditionPreviewModel], ((Int) -> Void)?)> {
    public override func makeNodeFrom(model: ([EditionPreviewModel], ((Int) -> Void)?), sizeConstraints: SizeConstraints) -> LayoutNode {
        let listNode = LayoutNode(config: { node in
            node.height = 160
            node.marginBottom = 8
        }) { (view: EditionListView, _) in
            view.openEdition = model.1
            view.set(editions: model.0)
        }

        return LayoutNode(children: [listNode])
    }
}
