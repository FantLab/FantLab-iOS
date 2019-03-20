import Foundation
import FLModels
import FLKit

extension EditionModel {
    public var biggestImageURL: URL? {
        return coverHDURL ?? image
    }
}

extension AuthorModel: ObjectPropertiesProvider {
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

extension EditionModel: ObjectPropertiesProvider {
    public var objectProperties: [ObjectProperty] {
        var properties: [ObjectProperty] = []

        if !lang.isEmpty {
            properties.append(("Язык", lang))
        }

        if !planDate.isEmpty {
            properties.append(("Дата выхода", planDate))
        } else if year > 0 {
            properties.append(("Год", String(year)))
        }

        if !publisher.isEmpty {
            properties.append(("Издатель", publisher))
        }

        if !coverType.isEmpty {
            properties.append(("Тип обложки", coverType))
        }

        if copies > 0 {
            properties.append(("Тираж", String(copies)))
        }

        if pages > 0 {
            properties.append(("Страниц", String(pages)))
        }

        if !format.isEmpty {
            properties.append(("Формат", format))
        }

        if !isbn.isEmpty {
            properties.append(("ISBN", isbn))
        }

        return properties
    }
}

extension UserProfileModel: ObjectPropertiesProvider {
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

extension WorkModel: ObjectPropertiesProvider {
    public var objectProperties: [ObjectProperty] {
        return classificatory.map({ genreGroup -> ObjectProperty in
            return (genreGroup.title, genreGroup.genres.map({ $0.label }).prefix(2).joined(separator: "\n"))
        })
    }
}

extension NewsModel: IntegerIdProvider {
    public var intId: Int {
        return id
    }
}

extension WorkPreviewModel: IntegerIdProvider {
    public var intId: Int {
        return id
    }
}

extension WorkReviewModel: IntegerIdProvider {
    public var intId: Int {
        return id
    }
}
