import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabLayoutSpecs
import FantLabStyle
import FantLabBaseUI
import SafariServices

final class AppRouter: NSObject, UINavigationControllerDelegate {
    static let shared = AppRouter()

    private override init() {
        super.init()

        do {
            navigationController.delegate = self

            Appearance.setup(navigationBar: navigationController.navigationBar)
        }

        do {
            let imageVC = ImageBackgroundViewController()
            imageVC.addChild(navigationController)
            imageVC.contentView.addSubview(navigationController.view)
            navigationController.view.pinEdges(to: imageVC.view)
            navigationController.didMove(toParent: imageVC)
            window.rootViewController = imageVC
        }

        do {
            window.makeKeyAndVisible()

            window.tintColor = Colors.flBlue
        }

        navigationController.pushViewController(SearchViewController(), animated: false)
    }

    let window = UIWindow()

    private let navigationController = UINavigationController()

    // MARK: -

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    // MARK: -

    func share(url: URL) {
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        navigationController.present(vc, animated: true, completion: nil)
    }

    func openWork(id: Int) {
        let vc = WorkViewController(workId: id)

        navigationController.pushViewController(vc, animated: true)
    }

    func openAuthor(id: Int) {
        let vc = AuthorViewController(authorId: id)

        navigationController.pushViewController(vc, animated: true)
    }

    func openEdition(id: Int) {
        let vc = EditionViewController(editionId: id)

        navigationController.pushViewController(vc, animated: true)
    }

    func openWorkReviews(workId: Int, reviewsCount: Int) {
        let vc = WorkReviewsViewController(workId: workId, reviewsCount: reviewsCount)

        navigationController.pushViewController(vc, animated: true)
    }

    func openReview(model: WorkReviewModel) {
        let item = ListItem(
            id: "review",
            layoutSpec: WorkReviewHeaderLayoutSpec(model: model)
        )

        openText(title: "Отзыв", string: model.text, customHeaderListItems: [item], makePhotoURL: nil)
    }

    func openText(title: String,
                  string: String,
                  customHeaderListItems: [ListItem],
                  makePhotoURL: ((Int) -> URL)?) {
        let vc = TextListViewController(
            string: string,
            customHeaderListItems: customHeaderListItems,
            makePhotoURL: makePhotoURL
        )

        vc.title = title

        navigationController.pushViewController(vc, animated: true)
    }

    func openAwards(_ awards: [AwardPreviewModel]) {
        let vc = AwardListViewController(awards: awards)

        navigationController.pushViewController(vc, animated: true)
    }

    func openEditionList(_ editionBlocks: [EditionBlockModel]) {
        let vc = EditionListViewController(editionBlocks: editionBlocks)

        navigationController.pushViewController(vc, animated: true)
    }

    func openURL(_ url: URL) {
        if let workString = url.path.firstMatch(for: "work\\d+"), let workId = Int(workString.dropFirst(4)) {
            openWork(id: workId)

            return
        }

        if let authorString = url.path.firstMatch(for: "autor\\d+"), let authorId = Int(authorString.dropFirst(5)) {
            openAuthor(id: authorId)

            return
        }

        if let editionString = url.path.firstMatch(for: "edition\\d+"), let editionId = Int(editionString.dropFirst(7)) {
            openEdition(id: editionId)

            return
        }

        if url.host != nil && (url.scheme == "http" || url.scheme == "https") {
            let vc = SFSafariViewController(url: url)
            vc.preferredControlTintColor = Colors.flBlue

            navigationController.present(vc, animated: true, completion: nil)

            return
        }
    }
}
