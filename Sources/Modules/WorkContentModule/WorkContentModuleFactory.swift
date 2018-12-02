import Foundation
import UIKit
import FantLabModels

public protocol WorkContentModuleRouter: class {
    func openWork(workId: Int)
}

public final class WorkContentModuleFactory {
    public static func makeModule(workModel: WorkModel, router: WorkContentModuleRouter) -> UIViewController {
        return WorkContentViewController(workModel: workModel, router: router)
    }
}
