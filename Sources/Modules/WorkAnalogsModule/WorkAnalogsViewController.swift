import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabSharedUI

final class WorkAnalogsViewController: ListViewController {
    private let analogModels: [WorkAnalogModel]
    private weak var router: WorkAnalogsModuleRouter?

    init(analogModels: [WorkAnalogModel], router: WorkAnalogsModuleRouter) {
        self.analogModels = analogModels
        self.router = router

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Похожие"

        var items: [ListItem] = []

        analogModels.forEach { model in
            let item = ListItem(
                id: UUID().uuidString,
                layoutSpec: WorkAnalogLayoutSpec(model: model)
            )

            item.actions.onSelect = { [weak self] in
                self?.router?.openWork(workId: model.id)
            }

            items.append(item)

            items.append(ListItem(
                id: UUID().uuidString,
                layoutSpec: ItemSeparatorLayoutSpec()
            ))
        }

        adapter.set(items: items)
    }
}
