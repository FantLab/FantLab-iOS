import Foundation
import UIKit
import ALLKit
import FantLabBaseUI
import FantLabModels
import FantLabLayoutSpecs
import FantLabStyle
import FantLabWebAPI
import FantLabUtils
import FantLabContentBuilders

final class EditionListViewController: ListViewController {
    private let editionBlocks: [EditionBlockModel]
    private let contentBuilder = EditionListContentBuilder()

    init(editionBlocks: [EditionBlockModel]) {
        self.editionBlocks = editionBlocks

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Все издания"

        contentBuilder.onEditionTap = { editionId in
            AppRouter.shared.openEdition(id: editionId)
        }

        DispatchQueue.global().async { [weak self] in
            let items = self?.contentBuilder.makeListItemsFrom(model: self?.editionBlocks ?? []) ?? []

            DispatchQueue.main.async {
                self?.adapter.set(items: items)
            }
        }
    }
}
