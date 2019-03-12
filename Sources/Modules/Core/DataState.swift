public enum DataState<T> {
    case initial
    case loading
    case error(Error)
    case success(T)

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

    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    // MARK: -

    public var error: Error? {
        if case let .error(error) = self { return error }
        return nil
    }

    public var data: T? {
        if case let .success(value) = self { return value }
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
        case let .success(data):
            return .success(transform(data))
        }
    }
}
