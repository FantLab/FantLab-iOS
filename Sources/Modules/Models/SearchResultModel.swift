public final class SearchResultModel {
    public let authors: [AuthorPreviewModel]
    public let works: [WorkPreviewModel]
    public let searchText: String

    public init(authors: [AuthorPreviewModel],
                works: [WorkPreviewModel],
                searchText: String) {

        self.authors = authors
        self.works = works
        self.searchText = searchText
    }
}
