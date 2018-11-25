import UIKit
import FantLabStyle
import FantLabTextUI
import FantLabSharedUI
import FantLabWorkModule
import FantLabWorkReviewsModule

public final class AppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let imageVC = ImageBackgroundViewController()

        let nc = UINavigationController()

        do {
            imageVC.addChild(nc)
            imageVC.contentView.addSubview(nc.view)
            nc.view.pinEdges(to: imageVC.contentView)
            nc.didMove(toParent: imageVC)
        }

        do {
            var router = WorkModuleRouter()
            router.openAuthor = { (entity, id) in }
            router.openWorkReviews = { workId in
                let vc = WorkReviewsModuleFactory.makeModule(workId: workId)
                nc.pushViewController(vc, animated: true)
            }
            router.showInteractiveText = { (title, text) in
                let vc = FLTextViewController(string: text)
                vc.title = title
                nc.pushViewController(vc, animated: true)
            }

            let vc = WorkModuleFactory.makeModule(workId: 3650, router: router) //  3650

            nc.pushViewController(vc, animated: true)
        }

        window = UIWindow()
        window?.rootViewController = imageVC
        window?.makeKeyAndVisible()

        window?.tintColor = AppStyle.shared.colors.mainTintColor

        Appearance.setup()

        return true
    }
}
