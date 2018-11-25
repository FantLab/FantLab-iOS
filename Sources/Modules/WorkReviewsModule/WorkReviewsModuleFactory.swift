import Foundation
import UIKit

public final class WorkReviewsModuleFactory {
    public static func makeModule(workId: Int) -> UIViewController {
        return WorkReviewsViewController(workId: workId)
    }
}
