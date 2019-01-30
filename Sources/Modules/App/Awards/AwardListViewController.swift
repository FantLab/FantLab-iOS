import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabStyle
import FantLabBaseUI
import FantLabLayoutSpecs

final class AwardListViewController: ListViewController {
    private let awards: [AwardPreviewModel]

    init(awards: [AwardPreviewModel]) {
        self.awards = awards

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Премии (\(awards.count))"

        DispatchQueue.global().async { [weak self] in
            let items = (self?.awards ?? []).enumerated().flatMap({ (i, award) -> [ListItem] in
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
                                self?.openWork(id: contest.workId)
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

            DispatchQueue.main.async {
                self?.adapter.set(items: items)
            }
        }
    }

    private func openWork(id: Int) {
        AppRouter.shared.openWork(id: id)
    }
}
