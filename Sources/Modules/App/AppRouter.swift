import Foundation
import UIKit
import FantLabModels
import FantLabTextUI
import FantLabWorkModule
import FantLabWorkReviewsModule
import FantLabWorkContentModule
import FantLabWorkAnalogsModule

final class AppRouter: WorkModuleRouter, WorkContentModuleRouter, WorkAnalogsModuleRouter {
    let rootNavigationController = UINavigationController()

    // MARK: -

    func openWork(workId: Int) {
        let vc = WorkModuleFactory.makeModule(workId: workId, router: self)

        rootNavigationController.pushViewController(vc, animated: true)
    }

    func openWorkReviews(workId: Int) {
        let vc = WorkReviewsModuleFactory.makeModule(workId: workId)

        rootNavigationController.pushViewController(vc, animated: true)
    }

    func openWorkContent(workModel: WorkModel) {
        guard !workModel.children.isEmpty else {
            return
        }

        let vc = WorkContentModuleFactory.makeModule(workModel: workModel, router: self)

        rootNavigationController.pushViewController(vc, animated: true)
    }

    func openAuthor(id: Int, entityName: String) {
        print(id, entityName)
    }

    func showWorkAnalogs(_ analogModels: [WorkAnalogModel]) {
        let vc = WorkAnalogsModuleFactory.makeModule(models: analogModels, router: self)
        
        rootNavigationController.pushViewController(vc, animated: true)
    }

    func showInteractiveText(_ text: String, title: String) {
        let vc = FLTextViewController(string: text)
        vc.title = title

        rootNavigationController.pushViewController(vc, animated: true)
    }
}
