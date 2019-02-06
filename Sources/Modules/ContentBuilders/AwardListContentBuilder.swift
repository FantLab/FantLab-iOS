import Foundation
import UIKit
import ALLKit
import FantLabUtils
import FantLabModels
import FantLabStyle
import FantLabLayoutSpecs

public final class AwardListContentBuilder: ListContentBuilder {
    public typealias ModelType = [AwardPreviewModel]

    // MARK: -

    public init() {}

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
                    item.didSelect = { [weak self] (cell, _) in
                        CellSelection.scale(cell: cell, action: {
                            self?.onWorkTap?(contest.workId)
                        })
                    }
                }

                return [item]
            })

            let sepItem = ListItem(
                id: "award_\(i)_separator",
                layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
            )

            return [item] + contestItems + [sepItem]
        })

        return items
    }
}
