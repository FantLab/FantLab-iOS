import Foundation
import FLKit
import FLModels

final class JSONConverter {
    private init() {}

    private static func isAuthorValid(id: Int) -> Bool {
        return id > 0 && id != 10 && id != 100 // Журнал и Межавторский цикл (для них бэк не отдает жсон как для других авторов)
    }

    static func makeWorkModelFrom(json: DynamicJSON) -> WorkModel {
        return WorkModel(
            id: json.work_id.intValue,
            name: json.work_name.stringValue,
            origName: json.work_name_orig.stringValue,
            year: json.work_year.intValue,
            workType: json.work_type.stringValue,
            workTypeKey: json.work_type_name.stringValue,
            publishStatuses: json.publish_statuses.array.map({ $0.stringValue }),
            rating: json.rating.rating.floatValue,
            votes: json.rating.voters.intValue,
            reviewsCount: json.val_responsecount.intValue,
            descriptionText: json.work_description.stringValue,
            descriptionAuthor: json.work_description_author.stringValue,
            notes: json.work_notes.stringValue,
            authors: json.authors.array.map({
                WorkModel.AuthorModel(
                    id: $0.id.intValue,
                    name: $0.name.stringValue,
                    type: $0.type.stringValue,
                    isOpened: $0.is_opened.boolValue
                )
            }).filter({
                isAuthorValid(id: $0.id)
            }),
            children: ChildWorkList(json.children.array.map({
                ChildWorkModel(
                    id: $0.work_id.intValue,
                    name: $0.work_name.stringValue,
                    origName: $0.work_name_orig.stringValue,
                    nameBonus: $0.work_name_bonus.stringValue,
                    rating: $0.val_midmark_by_weight.floatValue,
                    votes: $0.val_voters.intValue,
                    workType: $0.work_type.stringValue,
                    workTypeKey: $0.work_type_name.stringValue,
                    publishStatus: $0.publish_status.stringValue,
                    isPublished: $0.work_published.boolValue,
                    year: $0.work_year.intValue,
                    deepLevel: $0.deep.intValue,
                    plus: $0.plus.boolValue
                )
            })),
            parents: json.parents.cycles.array.map({
                $0.array.map({
                    WorkModel.ParentWorkModel(
                        id: $0.work_id.intValue,
                        name: $0.work_name.stringValue,
                        workType: $0.work_type.stringValue
                    )
                })
            }),
            classificatory: json.classificatory.genre_group.array.map({
                WorkModel.GenreGroupModel(
                    title: $0.label.stringValue,
                    genres: $0.genre.array.map({
                        makeWorkGenreFrom(json: $0)
                    })
                )
            }),
            awards: makeAwardListFrom(json: json.awards.win.array + json.awards.nom.array),
            editionBlocks: makeEditionBlocksFrom(json: json.editions_blocks)
        )
    }

    static func makeEditionBlocksFrom(json: DynamicJSON) -> [EditionBlockModel] {
        return json.keys.sorted().map { key -> EditionBlockModel in
            makeEditionBlockFrom(json: json[key])
        }
    }

    static func makeEditionBlockFrom(json: DynamicJSON) -> EditionBlockModel {
        return EditionBlockModel(
            type: json.name.stringValue,
            title: json.title.stringValue,
            list: json.list.array.map({
                EditionPreviewModel(
                    id: $0.edition_id.intValue,
                    langCode: $0.lang_code.stringValue,
                    year: $0.year.intValue,
                    coverURL: URL.web("/images/editions/big/\($0.edition_id.intValue)", host: Hosts.data),
                    correctLevel: $0.correct_level.floatValue
                )
            }).sorted(by: { (x, y) -> Bool in
                x.year > y.year
            })
        )
    }

    static func makeWorkGenreFrom(json: DynamicJSON) -> WorkModel.GenreGroupModel.GenreModel {
        return WorkModel.GenreGroupModel.GenreModel(
            id: json.genre_id.intValue,
            label: json.label.stringValue,
            votes: json.votes.intValue,
            percent: json.percent.floatValue,
            genres: json.genre.array.map({
                makeWorkGenreFrom(json: $0)
            })
        )
    }

    static func makeAwardListFrom(json: [DynamicJSON]) -> [AwardPreviewModel] {
        let jsonTable = Dictionary(grouping: json) { $0.award_id.stringValue }

        let awards = jsonTable.map { (_, group) in
            AwardPreviewModel(
                id: group[0].award_id.intValue,
                name: group[0].award_name.stringValue,
                rusName: group[0].award_rusname.stringValue,
                isOpen: group[0].award_is_opened.boolValue,
                iconURL: URL.web(group[0].award_icon.stringValue),
                contests: group.map({
                    AwardPreviewModel.ContestModel(
                        id: $0.contest_id.intValue,
                        year: $0.contest_year.intValue,
                        name: $0.nomination_rusname.string ?? $0.nomination_name.stringValue,
                        workId: $0.work_id.intValue,
                        workName: $0.work_rusname.string ?? $0.work_name.stringValue,
                        isWin: $0.cw_is_winner.boolValue
                    )
                }).sorted(by: { (x, y) -> Bool in
                    x.year < y.year
                })
            )
        }

        return awards.sorted(by: { (x, y) -> Bool in
            (x.rusName.nilIfEmpty ?? x.name).localizedCaseInsensitiveCompare(y.rusName.nilIfEmpty ?? y.name) == .orderedAscending
        })
    }

    static func makeWorkReviewsFrom(json: DynamicJSON) -> [WorkReviewModel] {
        return json.items.array.map {
            return WorkReviewModel(
                id: $0.response_id.intValue,
                date: Date.from(string: $0.response_date.stringValue, format: "yyyy-MM-dd HH:mm:ss"),
                text: $0.response_text.stringValue,
                votes: $0.response_votes.intValue,
                mark: $0.mark.intValue,
                user: WorkReviewModel.UserModel(
                    id: $0.user_id.intValue,
                    name: $0.user_name.stringValue,
                    avatar: URL.web($0.user_avatar.stringValue)
                ),
                work: WorkPreviewModel(
                    id: $0.work_id.intValue,
                    name: $0.work_name.stringValue.nilIfEmpty ?? $0.work_name_orig.stringValue,
                    type: $0.work_type.stringValue,
                    typeId: $0.work_type_id.intValue,
                    year: $0.work_year.intValue,
                    authors: [$0.work_author.string ?? $0.work_author_orig.stringValue],
                    rating: 0,
                    votes: 0
                )
            )
        }
    }

    static func makeWorkPreviewsFrom(json: DynamicJSON) -> [WorkPreviewModel] {
        return json.array.map {
            return WorkPreviewModel(
                id: $0.id.intValue,
                name: $0.name.stringValue.nilIfEmpty ?? $0.name_orig.stringValue,
                type: $0.name_type.stringValue,
                typeId: $0.name_type_id.intValue,
                year: $0.year.intValue,
                authors: $0.creators.authors.array.filter({
                    isAuthorValid(id: $0.id.intValue)
                }).map({
                    $0.name.string ?? $0.name_orig.stringValue
                }),
                rating: $0.stat.rating.floatValue,
                votes: $0.stat.voters.intValue
            )
        }
    }

    static func makeAuthorPreviewsFrom(json: DynamicJSON) -> [AuthorPreviewModel] {
        return json.array.map({
            AuthorPreviewModel(
                id: $0.id.intValue,
                name: $0.title.stringValue,
                photoURL: URL.web($0.image.stringValue)
            )
        })
    }

    static func makeAuthorModelFrom(json: DynamicJSON) -> AuthorModel {
        return AuthorModel(
            id: json.id.intValue,
            isOpened: json.is_opened.boolValue,
            name: json.name.stringValue,
            origName: json.name_orig.stringValue,
            pseudonyms: json.name_pseudonyms.array.map({ $0.name.string ?? $0.name_orig.stringValue }).filter({ !($0.isEmpty) }),
            countryName: json.country_name.stringValue,
            countryCode: json.country_id.stringValue,
            imageURL: URL.web(json.image.stringValue),
            birthDate: Date.from(string: json.birthday.stringValue, format: "yyyy-MM-dd"),
            deathDate: Date.from(string: json.deathday.stringValue, format: "yyyy-MM-dd"),
            bio: json.biography.stringValue,
            notes: json.biography_notes.stringValue,
            compiler: json.compiler.stringValue,
            sites: json.sites.array.compactMap({
                let title = $0.descr.stringValue

                guard let url = URL(string: $0.site.stringValue), !title.isEmpty else {
                    return nil
                }

                return AuthorModel.SiteModel(
                    link: url,
                    title: title
                )
            }),
            awards: makeAwardListFrom(json: json.awards.win.array + json.awards.nom.array),
            workBlocks: ChildWorkList((json.cycles_blocks.keys.map({ json.cycles_blocks[$0] }) + json.works_blocks.keys.map({ json.works_blocks[$0] })).flatMap(makeWorksBlockFrom))
        )
    }

    static func makeWorksBlockFrom(json: DynamicJSON) -> [ChildWorkModel] {
        var items: [ChildWorkModel] = [
            ChildWorkModel(
                id: 0,
                name: json.title.stringValue,
                origName: "",
                nameBonus: "",
                rating: 0,
                votes: 0,
                workType: "",
                workTypeKey: "",
                publishStatus: "",
                isPublished: true,
                year: 0,
                deepLevel: 1,
                plus: false
            )
        ]

        makeAuthorChildWorksFrom(json: json.list, storage: &items)

        return items
    }

    private static func makeAuthorChildWorksFrom(json: DynamicJSON, storage: inout [ChildWorkModel]) {
        json.array.forEach {
            let model = ChildWorkModel(
                id: $0.work_id.intValue,
                name: $0.work_name.stringValue,
                origName: $0.work_name_orig.stringValue,
                nameBonus: $0.work_name_bonus.stringValue,
                rating: $0.val_midmark_by_weight.floatValue,
                votes: $0.val_voters.intValue,
                workType: $0.work_type.stringValue,
                workTypeKey: $0.work_type_name.stringValue,
                publishStatus: $0.publish_status.stringValue,
                isPublished: $0.work_published.boolValue,
                year: $0.work_year.intValue,
                deepLevel: $0.deep.intValue + 2,
                plus: $0.plus.boolValue
            )

            storage.append(model)

            makeAuthorChildWorksFrom(json: $0.children, storage: &storage)
        }
    }

    static func makeEditionFrom(json: DynamicJSON) -> EditionModel {
        var isbn = json.isbns[0].stringValue

        // 978-2-2-07-25804-0 [<small>2-207-25804-1</small>]
        isbn = isbn.split(separator: " ").first.flatMap({ String($0) }) ?? isbn

        var format = json.format.stringValue
        format = format == "0" /* null */ ? "" : format

        let publisher = json.creators.publishers.array.map({ $0.name.stringValue }).compactAndJoin(" ")

        let images = json.images_plus.keys.flatMap({ json.images_plus[$0].array }).map({
            EditionModel.ImageModel(
                url: URL.web($0.image.stringValue),
                urlOrig: URL.web($0.image_orig.stringValue),
                text: $0.pic_text.stringValue
            )
        })

        return EditionModel(
            id: json.edition_id.intValue,
            name: json.edition_name.stringValue,
            image: URL.web(json.image.stringValue),
            coverHDURL: URL.web(json.images_plus.cover[0].image_orig.stringValue),
            images: images,
            correctLevel: json.correct_level.floatValue,
            year: json.year.intValue,
            planDate: json.plan_date.stringValue,
            type: json.edition_type.stringValue,
            copies: json.copies.intValue,
            pages: json.pages.intValue,
            coverType: json.cover_type.stringValue,
            publisher: publisher,
            format: format,
            isbn: isbn,
            lang: json.lang.stringValue,
            content: json.content.array.map({ $0.stringValue }),
            description: json["description"].stringValue,
            notes: json.notes.stringValue,
            planDescription: json.plan_description.stringValue
        )
    }

    static func makeUserProfileFrom(json: DynamicJSON) -> UserProfileModel {
        let sex: UserProfileModel.Sex?

        switch json.sex.stringValue {
        case "m":
            sex = .male
        case "f":
            sex = .female
        default:
            sex = nil
        }

        return UserProfileModel(
            id: json.user_id.intValue,
            login: json.login.stringValue,
            name: json.fio.stringValue,
            avatar: URL.web(json.avatar.stringValue),
            birthDate: Date.from(string: json.birthday.stringValue, format: "yyyy-MM-dd HH:mm:ss"),
            sex: sex,
            userClass: json.class_name.stringValue,
            location: json.location.stringValue,
            onlineDate: Date.from(string: json.date_of_last_action.stringValue, format: "yyyy-MM-dd HH:mm:ss"),
            registrationDate: Date.from(string: json.date_of_reg.stringValue, format: "yyyy-MM-dd HH:mm:ss"),
            isBlocked: json.block.boolValue,
            reviewsCount: json.responsecount.intValue
        )
    }

    static func makeNewsFrom(json: DynamicJSON) -> [NewsModel] {
        return json.items.array.compactMap({
            guard let date = Date.from(string: $0.date.stringValue, format: "yyyy-MM-dd HH:mm:ss") else {
                return nil
            }

            return NewsModel(
                id: $0.id.intValue,
                title: $0.title.stringValue,
                text: $0.news_text.stringValue,
                image: URL.web($0.image.stringValue),
                date: date,
                category: $0.category.stringValue
            )
        })
    }

    static func makePubNewsFrom(json: DynamicJSON) -> [PubNewsModel] {
        return json["objects"].array.map {
            PubNewsModel(
                editionId: $0.edition_id.intValue,
                dateString: $0.date.stringValue,
                imageURL: URL.web("/images/editions/small/\($0.edition_id.intValue)", host: Hosts.data),
                typeName: $0.type_name.stringValue,
                authors: $0.autors.stringValue,
                name: $0.name.stringValue,
                info: $0["description"].stringValue
            )
        }
    }
}
