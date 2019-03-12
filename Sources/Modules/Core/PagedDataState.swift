public struct PagedDataState<T> {
    public var items: [T]
    public var isFull: Bool
    public var page: Int
    public var state: DataState<Void>

    public init(items: [T],
                isFull: Bool,
                page: Int,
                state: DataState<Void>) {

        self.items = items
        self.isFull = isFull
        self.page = page
        self.state = state
    }
}
