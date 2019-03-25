import QuartzCore

public func timeOf<T>(_ body: () -> T) -> T {
    #if DEBUG
    let t1 = CACurrentMediaTime()
    defer {
        let t2 = CACurrentMediaTime()
        print("⏳", t2 - t1)
    }
    #endif
    return body()
}
