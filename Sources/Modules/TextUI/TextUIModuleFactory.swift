import Foundation
import UIKit
import ALLKit

public protocol TextUIModuleRouter: class {
    func open(url: URL)
}

public final class TextUIModuleFactory {
    public static func makeModule(string: String,
                                  customHeaderListItems: [ListItem],
                                  router: TextUIModuleRouter) -> UIViewController {
        return TextListViewController(
            string: string,
            customHeaderListItems: customHeaderListItems,
            router: router
        )
    }
}
