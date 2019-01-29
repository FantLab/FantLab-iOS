import Foundation
import UIKit
import ALLKit
import YYWebImage
import FantLabModels
import FantLabStyle

private final class EditionListView: UIView {
    private let adapter = CollectionViewAdapter(
        scrollDirection: .horizontal,
        sectionInset: .zero,
        minimumLineSpacing: 0,
        minimumInteritemSpacing: 0
    )

    override init(frame: CGRect) {
        super.init(frame: frame)

        adapter.collectionView.backgroundColor = UIColor.white
        adapter.collectionView.alwaysBounceHorizontal = true

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

        adapter.set(sizeConstraints: SizeConstraints(width: bounds.height * 0.75, height: bounds.height))
    }

    func set(editions: [EditionPreviewModel]) {
        DispatchQueue.global().async { [weak self] in
            let items: [ListItem] = editions.enumerated().map({
                let item = ListItem(
                    id: String($0.offset),
                    layoutSpec: EditionPreviewLayoutSpec(model: $0.element)
                )

                item.didSelect = { (cell, _) in
                    CellSelection.scale(cell: cell, action: {
                        // TODO:
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

public final class EditionListLayoutSpec: ModelLayoutSpec<[EditionPreviewModel]> {
    public override func makeNodeFrom(model: [EditionPreviewModel], sizeConstraints: SizeConstraints) -> LayoutNode {
        let listNode = LayoutNode(config: { node in
            node.height = 150
        }) { (view: EditionListView, _) in
            view.set(editions: model)
        }

        return listNode
    }
}
