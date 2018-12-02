import Foundation
import UIKit
import FantLabModels

public protocol WorkAnalogsModuleRouter: class {
    func openWork(workId: Int)
}

public final class WorkAnalogsModuleFactory {
    public static func makeModule(models: [WorkAnalogModel], router: WorkAnalogsModuleRouter) -> UIViewController {
        return WorkAnalogsViewController(analogModels: models, router: router)
    }
}
