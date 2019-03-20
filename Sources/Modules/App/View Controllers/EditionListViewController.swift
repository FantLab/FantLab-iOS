import Foundation
import UIKit
import ALLKit
import FLUIKit
import FLModels
import FLLayoutSpecs
import FLStyle
import FLWebAPI
import FLKit
import FLContentBuilders

final class EditionListViewController: ListViewController<EditionListContentBuilder> {
    init(editionBlocks: [EditionBlockModel]) {
        super.init(contentBuilder: EditionListContentBuilder())

        contentBuilder.onEditionTap = { editionId in
            AppRouter.shared.openEdition(id: editionId)
        }

        apply(viewState: editionBlocks)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
