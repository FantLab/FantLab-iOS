public final class SearchResultsModel {
    public final class WorkModel {
        public let id: Int
        public let name: String

        public init(id: Int,
                    name: String) {

            self.id = id
            self.name = name
        }
    }

    public let works: [WorkModel]

    public init(works: [WorkModel]) {
        self.works = works
    }
}
