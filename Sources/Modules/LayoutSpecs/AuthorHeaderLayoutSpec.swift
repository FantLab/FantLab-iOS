import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabStyle

public final class AuthorHeaderLayoutSpec: ModelLayoutSpec<AuthorModel> {
    public override func makeNodeFrom(model: AuthorModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let nameString: NSAttributedString
        let otherNamesString: NSAttributedString?
        let dateString: NSAttributedString?

        do {
            nameString = (model.name.nilIfEmpty ?? model.origName).attributed()
                .font(Fonts.system.bold(size: 22))
                .foregroundColor(UIColor.black)
                .make()

            let otherNamesText = (model.name != model.origName ? [model.origName] + model.pseudonyms : model.pseudonyms).compactAndJoin("\n")

            if !otherNamesText.isEmpty {
                otherNamesString = otherNamesText.attributed()
                    .font(Fonts.system.medium(size: 12))
                    .foregroundColor(UIColor.lightGray)
                    .make()
            } else {
                otherNamesString = nil
            }

            let birthDayString = model.birthDate.flatMap({ $0.format("dd.MM.yyyy") }) ?? ""
            let deathDayString = model.deathDate.flatMap({ $0.format("dd.MM.yyyy") }) ?? ""

            let dateText = [birthDayString, deathDayString].compactAndJoin(" - ")

            if !dateText.isEmpty {
                dateString = dateText.attributed()
                    .font(Fonts.system.medium(size: 10))
                    .foregroundColor(UIColor.gray)
                    .make()
            } else {
                dateString = nil
            }
        }

        let imageNode = LayoutNode(config: { node in
            node.width = 100
            node.height = 100
            node.marginLeft = 16
        }) { (view: UIImageView, _) in
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFill
            view.layer.cornerRadius = 50
            view.backgroundColor = Colors.perfectGray

            view.yy_setImage(with: model.imageURL, options: .setImageWithFadeAnimation)
        }

        let nameNode = LayoutNode(sizeProvider: nameString, config: nil) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = nameString
        }

        let otherNamesNode: LayoutNode?

        if let string = otherNamesString {
            otherNamesNode = LayoutNode(sizeProvider: string, config: { node in
                node.marginTop = 8
            }) { (label: UILabel, _) in
                label.numberOfLines = 0
                label.attributedText = string
            }
        } else {
            otherNamesNode = nil
        }

        let dateNode: LayoutNode?

        if let string = dateString {
            dateNode = LayoutNode(sizeProvider: string, config: { node in
                node.marginTop = 16
            }) { (label: UILabel, _) in
                label.numberOfLines = 0
                label.attributedText = string
            }
        } else {
            dateNode = nil
        }

        let textStackNode = LayoutNode(children: [nameNode, otherNamesNode, dateNode], config: { node in
            node.flexDirection = .column
            node.alignItems = .flexStart
            node.flex = 1
        })

        let contentNode = LayoutNode(children: [textStackNode, imageNode], config: { node in
            node.flexDirection = .row
            node.alignItems = .center
            node.padding(all: 16)
        })

        return contentNode
    }
}
