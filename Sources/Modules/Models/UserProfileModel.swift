import Foundation
import FLKit

public final class UserProfileModel: ObjectPropertiesProvider {
    public enum Sex {
        case male
        case female
    }

    public let id: Int
    public let login: String
    public let name: String
    public let avatar: URL?
    public let birthDate: Date?
    public let sex: Sex?
    public let userClass: String
    public let location: String
    public let onlineDate: Date?
    public let registrationDate: Date?
    public let isBlocked: Bool
    public let reviewsCount: Int

    public init(id: Int,
                login: String,
                name: String,
                avatar: URL?,
                birthDate: Date?,
                sex: Sex?,
                userClass: String,
                location: String,
                onlineDate: Date?,
                registrationDate: Date?,
                isBlocked: Bool,
                reviewsCount: Int) {

        self.id = id
        self.login = login
        self.name = name
        self.avatar = avatar
        self.birthDate = birthDate
        self.sex = sex
        self.userClass = userClass
        self.location = location
        self.onlineDate = onlineDate
        self.registrationDate = registrationDate
        self.isBlocked = isBlocked
        self.reviewsCount = reviewsCount
    }

    // MARK: -

    public var objectProperties: [ObjectProperty] {
        var properties: [ObjectProperty] = []

        if !name.isEmpty {
            properties.append(("ФИО", name))
        }

        if let sex = sex {
            switch sex {
            case .male:
                properties.append(("Пол", "Мужской"))
            case .female:
                properties.append(("Пол", "Женский"))
            }
        }

        if let birthDate = birthDate {
            properties.append(("День рождения", birthDate.format(.dayMonthAndYear)))
        }

        if !location.isEmpty {
            properties.append(("Место жительства", location))
        }

        if let registrationDate = registrationDate {
            properties.append(("Дата регистрации", registrationDate.format(.dayMonthAndYear)))
        }

        if let onlineDate = onlineDate {
            properties.append(("Последнее посещение", onlineDate.formatToHumanReadbleText()))
        }

        return properties
    }
}
