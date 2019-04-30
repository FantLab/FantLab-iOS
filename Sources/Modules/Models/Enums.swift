public enum ReviewsSort: String, CaseIterable {
    case date
    case rating
    case mark
}

public enum PubNewsType: String, CaseIterable {
    case pubnews
    case pubplans
}

public enum PubNewsSort: String, CaseIterable {
    case popularity // - по популярности (*)
    case date // - по дате (выхода)
    case type // - по типу (издания)
    case pub // - по издательству и серии
    case author // - по автору
    case title // - по наименованию
}

public enum PubNewsLang: Int {
    case ru = 0 // русскоязычное
    case other = 1 // зарубежное
}
