//
//  NewsLayoutSpec.swift
//  FantLabLayoutSpecs
//
//  Created by Geor Kasapidi on 16/02/2019.
//

import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabUtils
import FantLabStyle
import FantLabText

public final class NewsLayoutSpec: ModelLayoutSpec<NewsModel> {
    public override func makeNodeFrom(model: NewsModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        let titleString = (model.title.nilIfEmpty ?? "Новость").attributed()
            .font(Fonts.system.bold(size: 16))
            .foregroundColor(UIColor.black)
            .make()

        let dateString = model.date.formatToHumanReadbleText().attributed()
            .font(Fonts.system.regular(size: 11))
            .foregroundColor(UIColor.lightGray)
            .make()

        let textDrawing = FLStringPreview(string: model.text).value.attributed()
            .font(Fonts.system.regular(size: 15))
            .foregroundColor(UIColor.black)
            .lineSpacing(3)
            .make()
            .drawing(options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin])

        let titleNode = LayoutNode(sizeProvider: titleString, config: { node in
            node.marginBottom = 4
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = titleString
        }

        let dateNode = LayoutNode(sizeProvider: dateString, config: { node in
            node.marginBottom = 16
        }) { (label: UILabel, _) in
            label.numberOfLines = 0
            label.attributedText = dateString
        }

        let textNode = LayoutNode(sizeProvider: textDrawing, config: { node in
            node.maxHeight = 120
        }) { (label: AsyncLabel, _) in
            label.stringDrawing = textDrawing
        }

        let contentNode = LayoutNode(children: [titleNode, dateNode, textNode], config: { node in
            node.flexDirection = .column
            node.padding(all: 16)
        })

        return contentNode
    }
}
