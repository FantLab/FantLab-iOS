public enum DataState<T> {
    case initial
    case loading
    case error(Error)
    case idle(T)

    // MARK: -

    public var isInitial: Bool {
        if case .initial = self { return true }
        return false
    }

    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    public var isError: Bool {
        if case .error = self { return true }
        return false
    }

    public var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }

    // MARK: -

    public var data: T? {
        if case let .idle(value) = self { return value }
        return nil
    }

    public func map<NewT>(_ transform: (T) -> NewT) -> DataState<NewT> {
        switch self {
        case .initial:
            return .initial
        case .loading:
            return .loading
        case let .error(error):
            return .error(error)
        case let .idle(data):
            return .idle(transform(data))
        }
    }
}
