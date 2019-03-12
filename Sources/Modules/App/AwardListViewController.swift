import Foundation
import UIKit
import ALLKit
import FLModels
import FLStyle
import FLUIKit
import FLLayoutSpecs
import FLContentBuilders

final class AwardListViewController: ListViewController<AwardListContentBuilder> {
    init(awards: [AwardPreviewModel]) {
        super.init(contentBuilder: AwardListContentBuilder(useSectionSeparatorStyle: false))

        title = "Премии (\(awards.count))"

        contentBuilder.onWorkTap = { id in
            AppAnalytics.logWorkInAwardListTap()

            AppRouter.shared.openWork(id: id)
        }

        apply(viewState: awards)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
