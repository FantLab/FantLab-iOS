import UIKit.UIImage

public final class WorkTypeIcons {
    private init() {}

    public static func iconFor(workType: String) -> UIImage? {
        if workType == "antology" || workType == "collection" {
            return UIImage(named: "cycle")
        }

        return UIImage(named: workType) ?? UIImage(named: "shortstory")
    }
}
