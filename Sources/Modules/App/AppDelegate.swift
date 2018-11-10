import UIKit

public final class AppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow()
        window?.rootViewController = StartViewController()
        window?.makeKeyAndVisible()

        return true
    }
}
