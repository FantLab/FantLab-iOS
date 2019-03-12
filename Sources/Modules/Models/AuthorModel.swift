import Foundation
import FLKit

public final class AuthorModel: ObjectPropertiesProvider {
    public final class SiteModel {
        public let link: URL
        public let title: String

        public init(link: URL,
                    title: String) {

            self.link = link
            self.title = title
        }
    }

    public let id: Int
    public let isOpened: Bool
    public let name: String
    public let origName: String
    public let pseudonyms: [String]
    public let countryName: String
    public let countryCode: String
    public let imageURL: URL?
    public let birthDate: Date?
    public let deathDate: Date?
    public let bio: String
    public let notes: String
    public let compiler: String
    public let sites: [SiteModel]
    public let awards: [AwardPreviewModel]
    public let workBlocks: ChildWorkList

    public init(id: Int,
                isOpened: Bool,
                name: String,
                origName: String,
                pseudonyms: [String],
                countryName: String,
                countryCode: String,
                imageURL: URL?,
                birthDate: Date?,
                deathDate: Date?,
                bio: String,
                notes: String,
                compiler: String,
                sites: [SiteModel],
                awards: [AwardPreviewModel],
                workBlocks: ChildWorkList) {

        self.id = id
        self.isOpened = isOpened
        self.name = name
        self.origName = origName
        self.pseudonyms = pseudonyms
        self.countryName = countryName
        self.countryCode = countryCode
        self.imageURL = imageURL
        self.birthDate = birthDate
        self.deathDate = deathDate
        self.bio = bio
        self.notes = notes
        self.compiler = compiler
        self.sites = sites
        self.awards = awards
        self.workBlocks = workBlocks
    }

    // MARK: -

    public var objectProperties: [ObjectProperty] {
        var properties: [ObjectProperty] = []

        let pseudonymsString = pseudonyms.compactAndJoin("\n")

        if !pseudonyms.isEmpty {
            properties.append(("Псевдонимы", pseudonymsString))
        }

        if !countryName.isEmpty {
            properties.append(("Страна", countryName))
        }

        if let date = birthDate {
            properties.append(("Дата рождения", date.format(.dayMonthAndYear)))
        }

        if let date = deathDate {
            properties.append(("Дата смерти", date.format(.dayMonthAndYear)))
        }

        return properties
    }
}
