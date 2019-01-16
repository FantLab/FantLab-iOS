import Foundation
import UIKit
import ALLKit
import FantLabSharedUI
import FantLabModels
import FantLabStyle

final class WorkAwardListViewController: ListViewController {
    private let awards: [WorkModel.AwardModel]

    init(awards: [WorkModel.AwardModel]) {
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
                    layoutSpec: WorkAwardTitleLayoutSpec(model: award)
                )

                let contestItems = award.contests.enumerated().flatMap({ (j, contest) -> [ListItem] in
                    let item = ListItem(
                        id: "contest_\(i)_\(j)",
                        layoutSpec: WorkAwardContestLayoutSpec(model: contest)
                    )

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
}
