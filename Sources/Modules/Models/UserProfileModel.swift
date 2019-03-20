import Foundation

public final class UserProfileModel {
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
}
