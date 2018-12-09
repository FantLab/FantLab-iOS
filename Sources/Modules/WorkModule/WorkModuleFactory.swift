import Foundation
import UIKit
import FantLabModels

public protocol WorkModuleRouter: class {
    func showInteractiveText(_ text: String, title: String)
    func openAuthor(id: Int, entityName: String)
    func openWork(id: Int)
    func push(viewController: UIViewController)
}

public final class WorkModuleFactory {
    public static func makeModule(workId: Int, router: WorkModuleRouter) -> UIViewController {
        return WorkViewController(workId: workId, router: router)
    }
}
