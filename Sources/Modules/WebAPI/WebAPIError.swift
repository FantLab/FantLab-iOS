import FLKit

public enum WebAPIError: Error, ErrorHumanReadableTextConvertible {
    case notFound

    public var humanReadableDescription: String {
        switch self {
        case .notFound:
            return "Не найдено"
        }
    }
}
