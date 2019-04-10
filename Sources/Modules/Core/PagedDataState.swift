public struct PagedDataState<T: IntegerIdProvider> {
    public let id: String

    public init(id: String) {
        self.id = id
    }

    public var items: [[T]] = []
    public var ids: Set<Int> = []
    public var isFull: Bool = false
    public var page: Int = 0
    public var state: DataState<Void> = .initial
}
