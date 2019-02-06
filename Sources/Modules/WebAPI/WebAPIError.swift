import FantLabUtils

public enum WebAPIError: Error, ErrorHumanReadableTextConvertible {
    case notFound

    public var humanReadableDescription: String {
        switch self {
        case .notFound:
            return "По вашему запросу ничего не найдено"
        }
    }
}
