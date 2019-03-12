import Foundation

public protocol ErrorHumanReadableTextConvertible {
    var humanReadableDescription: String { get }
}

public final class ErrorHelper {
    private init() {}

    public static func isNetwork(error: Error) -> Bool {
        return (error as NSError).domain == NSURLErrorDomain
    }

    public static func makeHumanReadableTextFrom(error: Error) -> String {
        if isNetwork(error: error) {
            return "Не удалось подключиться к сети"
        }

        if let errorWithDescription = error as? ErrorHumanReadableTextConvertible {
            return errorWithDescription.humanReadableDescription
        }

        return "Что-то пошло не так"
    }
}
