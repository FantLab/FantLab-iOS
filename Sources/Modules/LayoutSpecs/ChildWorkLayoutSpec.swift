import Foundation
import UIKit
import ALLKit
import yoga
import FLModels
import FLStyle
import FLKit

public struct ChildWorkLayoutModel {
    public let work: ChildWorkModel
    public let count: Int
    public let isExpanded: Bool
    public let expandCollapseAction: (() -> Void)?

    public init(work: ChildWorkModel,
                count: Int,
                isExpanded: Bool,
                expandCollapseAction: (() -> Void)?) {

        self.work = work
        self.count = count
        self.isExpanded = isExpanded
        self.expandCollapseAction = expandCollapseAction
    }
}

public final class ChildWorkLayoutSpec: ModelLayoutSpec<ChildWorkLayoutModel> {
    public override func makeNodeFrom(model: ChildWorkLayoutModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let work = model.work

        let titleString: NSAttributedString
        let subtitleString: NSAttributedString?
        let detailString: NSAttributedString?

        do {
            let titleText = (work.plus ? "+ " : "") + (work.name.nilIfEmpty ?? work.origName)

            titleString = titleText.attributed()
                .font(work.id > 0 ? Fonts.system.medium(size: 14) : Fonts.system.regular(size: 14))
                .foregroundColor(work.isPublished ? UIColor.black : UIColor.lightGray)
                .make()

            let yearText = work.year > 0 ? String(work.year) : ""
            let typeText = work.workType.capitalizedFirstLetter()
            let subtitleText = ([typeText, yearText, work.publishStatus]).compactAndJoin(", ")

            subtitleString = subtitleText.nilIfEmpty?.attributed()
                .font(Fonts.system.regular(size: 12))
                .foregroundColor(UIColor.lightGray)
                .make()

            if !model.isExpanded && model.count > 0 {
                detailString = String(model.count).attributed()
                    .font(Fonts.system.regular(size: 15))
                    .foregroundColor(UIColor.lightGray)
                    .make()
            } else if work.rating > 0 && work.votes > 0 {
                let ratingColor = RatingColorRule.colorFor(rating: work.rating)

                detailString =
                    String(work.rating).attributed()
                        .font(Fonts.system.medium(size: 13))
                        .foregroundColor(ratingColor)
                        .alignment(.center)
                        .make()
                    +
                    ("\n" + String(work.votes)).attributed()
                        .font(Fonts.system.regular(size: 10))
                        .foregroundColor(UIColor.lightGray)
                        .alignment(.center)
                        .baselineOffset(-2)
                        .make()
            } else {
                detailString = nil
            }
        }

        let titleNode = LayoutNode(sizeProvider: titleString, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = titleString
        }

        let subtitleNode = LayoutNode(sizeProvider: subtitleString, config: { node in
            node.marginTop = 2
            node.isHidden = subtitleString == nil
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = subtitleString
        }

        let detailTextNode = LayoutNode(sizeProvider: detailString, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = detailString
        }

        let detailContainerNode = LayoutNode(children: [detailTextNode], config: { node in
            node.alignItems = .center
            node.flexDirection = .column
            node.width = 48
            node.marginLeft = 16
            node.isHidden = detailString == nil
        })

        let leftStackNode = LayoutNode(children: [titleNode, subtitleNode], config: { node in
            node.flex = 1
            node.flexDirection = .column
            node.alignItems = .flexStart
            node.minHeight = 20
        })

        let textContentStackNode = LayoutNode(children: [leftStackNode, detailContainerNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.justifyContent = .spaceBetween
            node.flex = 1
        })

        let rightArrowIconNode = LayoutNode(config: { node in
            node.width = 10
            node.height = 10
        }) { (view: UIImageView, _) in
            view.contentMode = .scaleAspectFit
            view.tintColor = UIColor.lightGray
            view.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
            view.isHidden = work.id < 1
        }

        let leftIconNode: LayoutNode

        if model.count > 0 {
            leftIconNode = LayoutNode(config: { node in
                node.marginRight = 10
                node.width = 8
                node.height = 8
            }) { (view: UIImageView, _) in
                view.contentMode = .scaleAspectFit
                view.tintColor = UIColor.lightGray
                view.image = (model.isExpanded ? UIImage(named: "arrow_up") : UIImage(named: "arrow_down"))?.withRenderingMode(.alwaysTemplate)
            }
        } else {
            leftIconNode = LayoutNode(config: { node in
                node.marginLeft = 1
                node.marginRight = 11
                node.width = 6
                node.height = 6
            }) { (view: UIImageView, _) in
                view.contentMode = .scaleAspectFit
                view.tintColor = UIColor.black
                view.image = WorkTypeIconRule.iconFor(workType: model.work.workTypeKey)?.withRenderingMode(.alwaysTemplate)
            }
        }

        let contentNode = LayoutNode(children: [leftIconNode, textContentStackNode, rightArrowIconNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: 12, left: nil, bottom: 12, right: 12)
            node.marginLeft = YGValue(CGFloat(work.deepLevel * 20))
        })

        let expandCollapseActionNode: LayoutNode?

        if let expandCollapseAction = model.expandCollapseAction {
            expandCollapseActionNode = LayoutNode(children: [], config: { node in
                node.position = .absolute
                node.top = 0
                node.left = 0
                node.bottom = 0
                node.width = 50%
            }) { (view: UIView, _) in
                view.all_addGestureRecognizer({ (_: UITapGestureRecognizer) in
                    expandCollapseAction()
                })
            }
        } else {
            expandCollapseActionNode = nil
        }

        return LayoutNode(children: [contentNode, expandCollapseActionNode])
    }
}
