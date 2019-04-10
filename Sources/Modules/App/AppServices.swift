import Foundation
import FLKit

final class AppServices {
    private init() {}

    static let network = NetworkClient(session: URLSession.shared)
    static let myBooks = MyBookService(fileName: "my_books.json")
}
