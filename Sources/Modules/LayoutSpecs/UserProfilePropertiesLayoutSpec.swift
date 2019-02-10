import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabStyle
import FantLabText

public final class UserProfilePropertiesLayoutSpec: ModelLayoutSpec<UserProfileModel> {
    public override func makeNodeFrom(model: UserProfileModel, sizeConstraints: SizeConstraints) -> LayoutNode {
        var properties: [(String, String)] = []

        if !model.name.isEmpty {
            properties.append(("ФИО", model.name))
        }

        if let sex = model.sex {
            switch sex {
            case .male:
                properties.append(("Пол", "Мужской"))
            case .female:
                properties.append(("Пол", "Женский"))
            }
        }

        if let birthDate = model.birthDate {
            properties.append(("День рождения", birthDate.format(.dayMonthAndYear)))
        }

        if !model.location.isEmpty {
            properties.append(("Место жительства", model.location))
        }

        if let registrationDate = model.registrationDate {
            properties.append(("Дата регистрации", registrationDate.format(.dayMonthAndYear)))
        }

        if let onlineDate = model.onlineDate {
            properties.append(("Последнее посещение", onlineDate.formatDayMonthAndYearIfNotCurrent()))
        }

        var textStackNodes: [LayoutNode] = []

        properties.enumerated().forEach { (index, property) in
            let titleString = property.0.capitalizedFirstLetter().attributed()
                .font(Fonts.system.regular(size: 14))
                .foregroundColor(UIColor.lightGray)
                .make()

            let contentString = property.1.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).capitalizedFirstLetter().attributed()
                .font(Fonts.system.regular(size: 14))
                .foregroundColor(UIColor.black)
                .make()

            let titleNode = LayoutNode(sizeProvider: titleString, config: { node in
                node.width = 48%
            }) { (label: UILabel, _) in
                label.numberOfLines = 0
                label.attributedText = titleString
            }

            let spacingNode = LayoutNode(config: { node in
                node.width = 2%
            })

            let contentNode = LayoutNode(sizeProvider: contentString, config: { node in
                node.width = 50%
            }) { (label: UILabel, _) in
                label.numberOfLines = 0
                label.attributedText = contentString
            }

            let textStackNode = LayoutNode(children: [titleNode, spacingNode, contentNode], config: { node in
                node.flexDirection = .row
                node.alignItems = .flexStart
                node.marginTop = 16
            })

            textStackNodes.append(textStackNode)
        }

        let contentNode = LayoutNode(children: textStackNodes, config: { node in
            node.flexDirection = .column
            node.alignItems = .flexStart
            node.padding(top: nil, left: 16, bottom: 16, right: 16)
        })

        return contentNode
    }
}
