import UIKit.UIImage

public final class WorkTypeIconRule {
    private init() {}

    public static func iconFor(workType: String) -> UIImage? {
        let key = workType.lowercased()

        if key == "antology" || key == "collection" {
            return UIImage(named: "cycle")
        }

        return UIImage(named: key) ?? UIImage(named: "shortstory")
    }
}
