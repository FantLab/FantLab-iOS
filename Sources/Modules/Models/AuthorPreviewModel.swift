import Foundation

public final class AuthorPreviewModel {
    public let id: Int
    public let name: String
    public let photoURL: URL?

    public init(id: Int,
                name: String,
                photoURL: URL?) {

        self.id = id
        self.name = name
        self.photoURL = photoURL
    }
}
