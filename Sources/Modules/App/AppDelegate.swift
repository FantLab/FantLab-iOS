import UIKit
import Fabric
import Crashlytics
import FantLabStyle
import FantLabBaseUI

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
        window = UIWindow()
        let rootNC = UINavigationController()
        rootNC.delegate = self
        
        Appearance.setup(navigationBar: rootNC.navigationBar)
        
        do {
            let imageVC = ImageBackgroundViewController()
            imageVC.addChild(rootNC)
            imageVC.contentView.addSubview(rootNC.view)
            rootNC.view.pinEdges(to: imageVC.view)
            rootNC.didMove(toParent: imageVC)
            window?.rootViewController = imageVC
        }
        window?.makeKeyAndVisible()

        window?.tintColor = Colors.flBlue

        #if DEBUG
        #else
        Fabric.with([Crashlytics.self])
        #endif

        rootNC.pushViewController(SearchViewController(), animated: true)

        return true
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
