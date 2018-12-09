import Foundation
import UIKit
import FantLabModels
import FantLabTextUI
import FantLabWorkModule

private final class RootNavigationController: UINavigationController {
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        topViewController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        super.pushViewController(viewController, animated: animated)
    }
}

final class AppRouter: WorkModuleRouter {
    let rootNavigationController: UINavigationController = RootNavigationController()

    // MARK: -

    func push(viewController: UIViewController) {
        rootNavigationController.pushViewController(viewController, animated: true)
    }

    func openWork(id workId: Int) {
        let vc = WorkModuleFactory.makeModule(workId: workId, router: self)

        rootNavigationController.pushViewController(vc, animated: true)
    }

    func openAuthor(id: Int, entityName: String) {
        print(id, entityName)
    }

    func showInteractiveText(_ text: String, title: String) {
        let vc = FLTextViewController(string: text)
        vc.title = title

        rootNavigationController.pushViewController(vc, animated: true)
    }
}
