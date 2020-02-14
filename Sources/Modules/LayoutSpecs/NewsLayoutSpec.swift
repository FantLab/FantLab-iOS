import Foundation
import UIKit
import ALLKit
import FLModels
import FLKit
import FLStyle
import FLText

public final class NewsHeaderLayoutSpec: ModelLayoutSpec<NewsModel> {
    public override func makeNodeFrom(model: NewsModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let titleString = (model.title.nilIfEmpty ?? "Новость").attributed()
            .font(Fonts.system.bold(size: 16))
            .foregroundColor(UIColor.black)
            .make()

        let dateString = model.date.formatToHumanReadbleText().attributed()
            .font(Fonts.system.regular(size: 11))
            .foregroundColor(UIColor.lightGray)
            .make()

        let tagString = model.category.attributed()
            .font(Fonts.system.bold(size: 14))
            .foregroundColor(UIColor.white)
            .make()

        let tagColor: UIColor

        switch model.category {
        case "некролог":
            tagColor = UIColor.black
        case "не фантастика":
            tagColor = UIColor(rgb: 0x718759)
        case "в мире Ф&Ф":
            tagColor = UIColor(rgb: 0x018213)
        case "внимание!":
            tagColor = UIColor(rgb: 0xDD171D)
        case "обо всём":
            tagColor = UIColor(rgb: 0xC45E24)
        default:
            tagColor = UIColor(rgb: 0x3178A8)
        }

        let titleNode = LayoutNode(sizeProvider: titleString, {

        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = titleString
        }

        let dateNode = LayoutNode(sizeProvider: dateString, {
            node.marginTop = 4
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = dateString
        }

        let tagNode = LayoutNode(sizeProvider: tagString, {

        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = tagString
        }

        let tagContainerNode = LayoutNode(children: [tagNode], {
            node.alignItems = .center
            node.justifyContent = .center
            node.padding(top: 2, left: 4, bottom: 2, right: 4)
            node.marginTop = 8
        }) { (view: UIView, _) in
            view.layer.cornerRadius = 2
            view.backgroundColor = tagColor
        }

        let leftStackNode = LayoutNode(children: [titleNode, dateNode, tagContainerNode], {
            node.flexDirection = .column
            node.justifyContent = .flexStart
            node.alignItems = .flexStart
            node.flex = 1
            node.marginRight = 16
        })

        let imageNode = LayoutNode({
            node.width = 80
            node.height = 80
        }) { (imageView: UIImageView, _) in
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFit

            WebImage.load(url: model.image, into: imageView)
        }

        let contentNode = LayoutNode(children: [leftStackNode, imageNode], {
            node.flexDirection = .row
            node.padding(top: 16, left: 16, bottom: nil, right: 16)
        })

        return contentNode
    }
}
