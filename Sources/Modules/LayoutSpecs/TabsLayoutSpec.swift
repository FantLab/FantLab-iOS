import Foundation
import UIKit
import ALLKit
import yoga
import FantLabStyle

public struct TabLayoutModel {
    public let name: String
    public let count: Int
    public let isSelected: Bool
    public let action: () -> Void

    public init(name: String,
                count: Int,
                isSelected: Bool,
                action: @escaping () -> Void) {

        self.name = name
        self.count = count
        self.isSelected = isSelected
        self.action = action
    }
}

public final class TabsLayoutSpec: ModelLayoutSpec<[TabLayoutModel]> {
    public override func makeNodeFrom(model: [TabLayoutModel], sizeConstraints: SizeConstraints) -> LayoutNode {
        var tabNodes: [LayoutNode] = []

        let tabWidth = (1.0 / Float(max(model.count, 1))) * 100

        let backgroundColor: UIColor = Colors.perfectGray

        model.forEach { tab in
            let nameString = tab.name.attributed()
                .font(Fonts.system.regular(size: 14))
                .foregroundColor(UIColor.black)
                .alignment(.center)
                .lineBreakMode(.byTruncatingTail)
                .make()

            let nameNode = LayoutNode(sizeProvider: nameString, config: nil) { (label: UILabel, _) in
                label.attributedText = nameString
            }

            let countNode: LayoutNode?

            if tab.count > 0 {
                let countString = String(tab.count).attributed()
                    .font(Fonts.system.regular(size: 10))
                    .foregroundColor(UIColor.lightGray)
                    .make()

                countNode = LayoutNode(sizeProvider: countString, config: { node in
                    node.marginLeft = 3
                    node.marginBottom = 4
                }) { (label: UILabel, _) in
                    label.attributedText = countString
                }
            } else {
                countNode = nil
            }

            let tabContentNode = LayoutNode(children: [nameNode, countNode], config: { node in
                node.flexDirection = .row
                node.alignItems = .center
                node.flex = 1
                node.marginLeft = 16
                node.marginRight = 16
            })

            let selectionLineNode: LayoutNode?

            if tab.isSelected {
                selectionLineNode = LayoutNode(config: { node in
                    node.position = .absolute
                    node.height = 2
                    node.left = 0
                    node.bottom = 0
                    node.right = 0
                }) { (view: UIView, _) in
                    view.backgroundColor = Colors.flOrange
                }
            } else {
                selectionLineNode = nil
            }

            let tabNode = LayoutNode(children: [tabContentNode, selectionLineNode], config: { node in
                node.width = YGValue(value: tabWidth, unit: .percent)
                node.alignItems = .center
                node.justifyContent = .center
                node.paddingTop = 12
                node.paddingBottom = 12
            }) { (view: UIView, _) in
                view.all_addGestureRecognizer({ (_: UITapGestureRecognizer) in
                    tab.action()
                })
            }

            tabNodes.append(tabNode)
        }

        let tabsNode = LayoutNode(children: tabNodes, config: { node in
            node.flexDirection = .row
            node.marginTop = 8
            node.marginBottom = 8
        }) { (view: UIView, _) in
            view.backgroundColor = backgroundColor
            view.superview?.sendSubviewToBack(view)
        }

        return LayoutNode(children: [tabsNode])
    }
}
