import Foundation
import UIKit

public struct WorkModuleRouter {
    public init() {}

    public var openWorkReviews: ((Int) -> Void)?
    public var openAuthor: ((String, Int) -> Void)?
    public var showInteractiveText: ((String, String) -> Void)?
}

public final class WorkModuleFactory {
    public static func makeModule(workId: Int, router: WorkModuleRouter) -> UIViewController {
        return WorkViewController(workId: workId, router: router)
    }
}
