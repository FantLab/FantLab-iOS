public enum DataState<T> {
    case initial
    case loading
    case error
    case idle(T)

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
}
