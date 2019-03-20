import Foundation

public final class WorkReviewModel {
    public final class UserModel {
        public let id: Int
        public let name: String
        public let avatar: URL?

        public init(id: Int,
                    name: String,
                    avatar: URL?) {

            self.id = id
            self.name = name
            self.avatar = avatar
        }
    }

    public let id: Int
    public let date: Date?
    public let text: String
    public let votes: Int
    public let mark: Int
    public let user: UserModel
    public let work: WorkPreviewModel

    public init(id: Int,
                date: Date?,
                text: String,
                votes: Int,
                mark: Int,
                user: UserModel,
                work: WorkPreviewModel) {

        self.id = id
        self.date = date
        self.text = text
        self.votes = votes
        self.mark = mark
        self.user = user
        self.work = work
    }
}
