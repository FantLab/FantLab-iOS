import UIKit
import FLKit
import FLUIKit
#if !DEBUG
import Firebase
import Fabric
import Crashlytics
#endif

public func runApp() {
    UIApplicationMain(CommandLine.argc,
                      CommandLine.unsafeArgv,
                      NSStringFromClass(Application.self),
                      NSStringFromClass(AppDelegate.self))
}

private final class Application: UIApplication {}

private final class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        window = AppRouter.shared.window

        #if DEBUG
        print("🔥", FileUtils.docDir)
        #else
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        #endif

        return true
    }
}
