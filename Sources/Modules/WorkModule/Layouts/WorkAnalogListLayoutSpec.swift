import Foundation
import UIKit
import ALLKit
import yoga
import FantLabModels
import FantLabUtils
import FantLabStyle
import FantLabSharedUI

private final class WorkAnalogLayoutSpec: ModelLayoutSpec<WorkAnalogModel> {
    override func makeNodeFrom(model: WorkAnalogModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString: NSAttributedString
        let authorString: NSAttributedString?
        
        do {
            nameString = (model.name.nilIfEmpty ?? model.nameOrig).attributed()
                .font(Fonts.system.medium(size: 13))
                .foregroundColor(UIColor.black)
                .alignment(.center)
                .make()

            authorString = model.authors.first?.nilIfEmpty?.attributed()
                .font(Fonts.system.regular(size: 10))
                .foregroundColor(UIColor.lightGray)
                .alignment(.center)
                .make()
        }

        let nameNode = LayoutNode(sizeProvider: nameString, config: { node in
            node.maxHeight = 150
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let authorNode = LayoutNode(sizeProvider: authorString, config: { node in
            node.isHidden = authorString == nil
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = authorString
        }

        let contentNode = LayoutNode(children: [nameNode, authorNode], config: { node in
            node.flexDirection = .column
            node.alignItems = .center
            node.justifyContent = .spaceBetween
            node.padding(all: 16)
            node.width = 140
            node.flex = 1
        }) { (view: UIView) in
            view.backgroundColor = UIColor.white
            view.layer.cornerRadius = 8
            view.layer.shouldRasterize = true
            view.layer.rasterizationScale = UIScreen.main.scale
            view.layer.shadowOpacity = 1
            view.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 8
        }

        return LayoutNode(children: [contentNode], config: { node in
            node.padding(top: 20, left: 12, bottom: 24, right: 12)
        })
    }
}

private final class WorkAnalogListView: UIView {
    private let adapter = CollectionViewAdapter(
        scrollDirection: .horizontal,
        sectionInset: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12),
        minimumLineSpacing: 0,
        minimumInteritemSpacing: 0
    )

    override init(frame: CGRect) {
        super.init(frame: frame)



        adapter.collectionView.alwaysBounceHorizontal = true
        adapter.collectionView.showsHorizontalScrollIndicator = false
        adapter.collectionView.backgroundColor = UIColor.white
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
        adapter.set(sizeConstraints: SizeConstraints(width: nil, height: bounds.height))
    }

    func show(models: [WorkAnalogModel], onSelect: @escaping (Int) -> Void) {
        DispatchQueue.global().async { [weak self] in
            let items: [ListItem] = models.map({ model in
                let item = ListItem(
                    id: String(model.id),
                    layoutSpec: WorkAnalogLayoutSpec(model: model)
                )

                item.didHighlight = { cell in
                    UIView.animate(withDuration: 0.1, animations: {
                        cell.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
                    })
                }

                item.didUnhighlight = { cell in
                    UIView.animate(withDuration: 0.15, animations: {
                        cell.transform = CGAffineTransform.identity
                    })
                }

                item.selectAction = {
                    onSelect(model.id)
                }

                return item
            })

            DispatchQueue.main.async {
                self?.adapter.set(items: items)
            }
        }
    }
}

final class WorkAnalogListLayoutSpec: ModelLayoutSpec<([WorkAnalogModel], (Int) -> Void)> {
    override func makeNodeFrom(model: ([WorkAnalogModel], (Int) -> Void), sizeConstraints: SizeConstraints) -> LayoutNode {
        let listNode = LayoutNode(config: { node in
            node.height = 240
        }) { (view: WorkAnalogListView) in
            view.show(models: model.0, onSelect: model.1)
        }

        return listNode
    }
}
