import UIKit
import Fabric
import Crashlytics
import FantLabStyle
import FantLabTextUI
import FantLabSharedUI
import FantLabWorkModule
import FantLabWorkReviewsModule

public final class AppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?

    private let router = AppRouter()

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow()
        window?.rootViewController = router.rootNavigationController
        window?.makeKeyAndVisible()

        window?.tintColor = AppStyle.colors.mainTintColor

        Appearance.setup()

        #if DEBUG
        #else
        Fabric.with([Crashlytics.self])
        #endif

        router.openWork(workId: 502648)

        return true
    }
}
