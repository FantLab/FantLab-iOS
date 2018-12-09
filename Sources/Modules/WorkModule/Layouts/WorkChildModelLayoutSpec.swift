import Foundation
import UIKit
import ALLKit
import yoga
import FantLabModels
import FantLabStyle
import FantLabUtils
import FantLabSharedUI

struct ChildWorkModelLayoutModel {
    let work: WorkModel.ChildWorkModel
    let count: Int
    let isExpanded: Bool
    let expandCollapseAction: (() -> Void)?
}

final class ChildWorkModelLayoutSpec: ModelLayoutSpec<ChildWorkModelLayoutModel> {
    override func makeNodeFrom(model: ChildWorkModelLayoutModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let work = model.work

        let titleString: NSAttributedString
        let subtitleString: NSAttributedString?
        let detailString: NSAttributedString?

        do {
            let titleText = (work.plus ? "+ " : "") + (work.name.nilIfEmpty ?? work.origName)

            let useBold = !work.name.isEmpty && work.id > 0

            titleString = titleText.attributed()
                .font(useBold ? Fonts.system.medium(size: 15) : Fonts.system.regular(size: 15))
                .foregroundColor(work.isPublished ? UIColor.black : UIColor.lightGray)
                .make()

            let yearText = work.year > 0 ? String(work.year) : ""
            let typeText = work.workType.capitalizedFirstLetter()
            let subtitleText = ([typeText, yearText, work.publishStatus]).compactAndJoin(", ")

            subtitleString = subtitleText.nilIfEmpty?.attributed()
                .font(Fonts.system.regular(size: 13))
                .foregroundColor(UIColor.lightGray)
                .make()

            if !model.isExpanded && model.count > 0 {
                detailString = String(model.count).attributed()
                    .font(Fonts.system.regular(size: 15))
                    .foregroundColor(UIColor.lightGray)
                    .make()
            } else if work.rating > 0 && work.votes > 0 {
                let ratingColor = RatingColorRule.colorFor(rating: work.rating)

                let ratingString = String(work.rating).attributed()
                    .font(Fonts.system.medium(size: 13))
                    .foregroundColor(ratingColor)
                    .alignment(.center)
                    .makeMutable()

                let votesString = ("\n" + String(work.votes)).attributed()
                    .font(Fonts.system.regular(size: 10))
                    .foregroundColor(UIColor.lightGray)
                    .alignment(.center)
                    .baselineOffset(-2)
                    .make()

                ratingString.append(votesString)

                detailString = ratingString
            } else {
                detailString = nil
            }
        }

        let titleNode = LayoutNode(sizeProvider: titleString, config: nil) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = titleString
        }

        let subtitleNode = LayoutNode(sizeProvider: subtitleString, config: { node in
            node.marginTop = 2
            node.isHidden = subtitleString == nil
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = subtitleString
        }

        let detailTextNode = LayoutNode(sizeProvider: detailString, config: nil) { (label: UILabel) in
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
            node.width = 12
            node.height = 12
        }) { (view: UIImageView) in
            view.contentMode = .scaleAspectFit
            view.tintColor = UIColor(rgb: 0xC8C7CC)
            view.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
            view.isHidden = work.id < 1
        }

        let expandCollapseIconNode = LayoutNode(config: { node in
            node.marginRight = 12
            node.width = 10
            node.height = 10
        }) { (view: UIImageView) in
            view.contentMode = .scaleAspectFit
            view.tintColor = UIColor(rgb: 0xC8C7CC)
            view.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate).with(orientation: model.isExpanded ? .left : .right)
            view.isHidden = model.count < 1
        }

        let expandCollapseActionNode: LayoutNode?

        if let expandCollapseAction = model.expandCollapseAction {
            expandCollapseActionNode = LayoutNode(children: [], config: { node in
                node.position = .absolute
                node.top = 0
                node.left = 0
                node.bottom = 0
                node.width = 50%
            }) { (view: UIView) in
                view.all_addGestureRecognizer({ (_: UITapGestureRecognizer) in
                    expandCollapseAction()
                })
            }
        } else {
            expandCollapseActionNode = nil
        }

        let contentNode = LayoutNode(children: [expandCollapseIconNode, textContentStackNode, rightArrowIconNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: 12, left: nil, bottom: 12, right: 12)
            node.marginLeft = YGValue(CGFloat(work.deepLevel * 20))
        })

        return LayoutNode(children: [contentNode, expandCollapseActionNode])
    }
}

final class WorkChildModelLayoutSpec: ModelLayoutSpec<WorkModel.ChildWorkModel> {
    override func makeNodeFrom(model: WorkModel.ChildWorkModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let work = model

        let titleString: NSAttributedString
        let subtitleString: NSAttributedString?
        let detailString: NSAttributedString?

        do {
            let titleText = (work.plus ? "+ " : "") + (work.name.nilIfEmpty ?? work.origName)

            let useBold = !work.name.isEmpty && work.id > 0

            titleString = titleText.attributed()
                .font(useBold ? Fonts.system.medium(size: 13) : Fonts.system.regular(size: 13))
                .foregroundColor(work.isPublished ? UIColor.black : UIColor.lightGray)
                .make()

            let yearText = work.year > 0 ? String(work.year) : ""
            let typeText = work.workType.capitalizedFirstLetter()
            let subtitleText = ([typeText, yearText, work.publishStatus]).compactAndJoin(", ")

            subtitleString = subtitleText.nilIfEmpty?.attributed()
                .font(Fonts.system.regular(size: 11))
                .foregroundColor(UIColor.lightGray)
                .make()

            if work.rating > 0 && work.votes > 0 {
                let ratingColor = RatingColorRule.colorFor(rating: work.rating)

                let ratingString = String(work.rating).attributed()
                    .font(Fonts.system.medium(size: 13))
                    .foregroundColor(ratingColor)
                    .alignment(.center)
                    .makeMutable()

                let votesString = ("\n" + String(work.votes)).attributed()
                    .font(Fonts.system.regular(size: 10))
                    .foregroundColor(UIColor.lightGray)
                    .alignment(.center)
                    .baselineOffset(-2)
                    .make()

                ratingString.append(votesString)

                detailString = ratingString
            } else {
                detailString = nil
            }
        }

        let titleNode = LayoutNode(sizeProvider: titleString, config: nil) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = titleString
        }

        let subtitleNode = LayoutNode(sizeProvider: subtitleString, config: { node in
            node.marginTop = 2
            node.isHidden = subtitleString == nil
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = subtitleString
        }

        let detailNode = LayoutNode(sizeProvider: detailString, config: { node in
            node.isHidden = detailString == nil
        }) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = detailString
        }

        let detailContainerNode = LayoutNode(children: [detailNode], config: { node in
            node.alignItems = .center
            node.flexDirection = .column
            node.width = 48
            node.marginLeft = 16
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
            node.width = 12
            node.height = 12
        }) { (view: UIImageView) in
            view.contentMode = .scaleAspectFit
            view.tintColor = UIColor(rgb: 0xC8C7CC)
            view.image = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
            view.isHidden = work.id < 1
        }

        let contentNode = LayoutNode(children: [textContentStackNode, rightArrowIconNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(top: 16, left: nil, bottom: 16, right: 12)
            node.marginLeft = YGValue(CGFloat(work.deepLevel * 16))
        })

        return LayoutNode(children: [contentNode])
    }
}

