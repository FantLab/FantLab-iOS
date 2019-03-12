import Foundation
import UIKit
import ALLKit
import FLKit
import FLModels
import FLStyle
import FLLayoutSpecs

public final class AwardListContentBuilder: ListContentBuilder {
    public typealias ModelType = [AwardPreviewModel]

    // MARK: -

    private let useSectionSeparatorStyle: Bool

    public init(useSectionSeparatorStyle: Bool) {
        self.useSectionSeparatorStyle = useSectionSeparatorStyle
    }

    // MARK: -

    public var onWorkTap: ((Int) -> Void)?

    // MARK: -

    public func makeListItemsFrom(model: [AwardPreviewModel]) -> [ListItem] {
        let items = model.enumerated().flatMap({ (i, award) -> [ListItem] in
            let item = ListItem(
                id: "award_\(i)",
                layoutSpec: AwardTitleLayoutSpec(model: award)
            )

            let contestItems = award.contests.enumerated().flatMap({ (j, contest) -> [ListItem] in
                let item = ListItem(
                    id: "contest_\(i)_\(j)",
                    layoutSpec: AwardContestLayoutSpec(model: contest)
                )

                if contest.workId > 0 {
                    item.didSelect = { [weak self] (view, _) in
                        view.animated(action: { [weak self] in
                            self?.onWorkTap?(contest.workId)
                        })
                    }
                }

                return [item]
            })

            let sepSpec: LayoutSpec = useSectionSeparatorStyle ? EmptySpaceLayoutSpec(model: (Colors.perfectGray, 8)) : ItemSeparatorLayoutSpec(model: Colors.separatorColor)

            let sepItem = ListItem(
                id: "award_\(i)_sep",
                layoutSpec: sepSpec
            )

            return [item] + contestItems + [sepItem]
        })

        return items
    }
}
