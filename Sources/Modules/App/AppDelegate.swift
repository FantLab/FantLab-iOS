import UIKit
import Fabric
import Crashlytics
import FantLabStyle
import FantLabTextUI
import FantLabSharedUI
import FantLabWorkModule

public func runApp() {
    UIApplicationMain(CommandLine.argc,
                      CommandLine.unsafeArgv,
                      NSStringFromClass(Application.self),
                      NSStringFromClass(AppDelegate.self))
}

private final class Application: UIApplication {}

private final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private let router = AppRouter()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow()
        do {
            let rootNC = router.rootNavigationController
            let imageVC = ImageBackgroundViewController()
            imageVC.addChild(rootNC)
            imageVC.contentView.addSubview(rootNC.view)
            rootNC.view.pinEdges(to: imageVC.view)
            rootNC.didMove(toParent: imageVC)
            window?.rootViewController = imageVC
        }
        window?.makeKeyAndVisible()

        window?.tintColor = Colors.flBlue

        Appearance.setup()

        #if DEBUG
        #else
        Fabric.with([Crashlytics.self])
        #endif

        let searchController = SearchViewController()
        searchController.openWork = { [weak self] workId in
            self?.router.openWork(id: workId)
        }

        router.rootNavigationController.pushViewController(searchController, animated: true)

        return true
    }
}
