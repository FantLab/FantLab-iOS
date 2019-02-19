import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabStyle
import FantLabBaseUI
import FantLabLayoutSpecs
import FantLabContentBuilders

final class AwardListViewController: ListViewController {
    private let awards: [AwardPreviewModel]
    private let contentBuilder = AwardListContentBuilder()

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

        contentBuilder.onWorkTap = { id in
            AppAnalytics.logWorkInAwardListTap()

            AppRouter.shared.openWork(id: id)
        }

        DispatchQueue.global().async { [weak self] in
            self?.setupUI()
        }
    }

    // MARK: -

    private func setupUI() {
        let items = contentBuilder.makeListItemsFrom(model: awards)

        DispatchQueue.main.async { [weak self] in
            self?.adapter.set(items: items)
        }
    }
}
