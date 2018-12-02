import Foundation
import UIKit
import FantLabModels

public protocol WorkModuleRouter: class {
    func showInteractiveText(_ text: String, title: String)
    func openWorkReviews(workId: Int)
    func openWorkContent(workModel: WorkModel)
    func openAuthor(id: Int, entityName: String)
    func showWorkAnalogs(_ analogModels: [WorkAnalogModel])
}

public final class WorkModuleFactory {
    public static func makeModule(workId: Int, router: WorkModuleRouter) -> UIViewController {
        return WorkViewController(workId: workId, router: router)
    }
}
