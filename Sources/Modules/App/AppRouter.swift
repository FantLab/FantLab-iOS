import Foundation
import UIKit
import SafariServices
import AVFoundation
import RxSwift
import ALLKit
import FantLabModels
import FantLabContentBuilders
import FantLabStyle
import FantLabBaseUI
import FantLabWebAPI
import FantLabUtils

final class AppRouter {
    static let shared = AppRouter()

    private init() {
        do {
            let imageVC = ImageBackgroundViewController()
            imageVC.addChild(rootNavigationController)
            imageVC.contentView.addSubview(rootNavigationController.view)
            rootNavigationController.view.pinEdges(to: imageVC.view)
            rootNavigationController.didMove(toParent: imageVC)
            window.rootViewController = imageVC
        }

        do {
            window.tintColor = Colors.flBlue
            window.makeKeyAndVisible()
        }

        do {
            rootNavigationController.willShowVC = { [weak self] vc in
                self?.setupNavigationItemsFor(viewController: vc)
            }
        }

        do {
            var vcs: [UIViewController] = []

            do {
                let newsVC = NewsViewController()

                newsVC.title = "Новости"

                newsVC.tabBarItem = UITabBarItem(title: "Главная", image: UIImage(named: "home_tab"), tag: 1)

                let cameraItem = navBarItemsFactory.makeCameraItem { [weak self] in
                    self?.tryShowScanner()
                }

                let searchItem = navBarItemsFactory.makeSearchItem { [weak self] in
                    self?.showSearch()
                }

                newsVC.navBar.leftItems = [cameraItem]
                newsVC.navBar.rightItems = [searchItem]

                vcs.append(newsVC)
            }

            do {
                let freshReviewsVC = FreshReviewsViewController()

                freshReviewsVC.title = "Последние отзывы"

                freshReviewsVC.tabBarItem = UITabBarItem(title: "Отзывы", image: UIImage(named: "reviews_tab"), tag: 2)

                let cameraItem = navBarItemsFactory.makeCameraItem { [weak self] in
                    self?.tryShowScanner()
                }

                let searchItem = navBarItemsFactory.makeSearchItem { [weak self] in
                    self?.showSearch()
                }

                freshReviewsVC.navBar.leftItems = [cameraItem]
                freshReviewsVC.navBar.rightItems = [searchItem]

                vcs.append(freshReviewsVC)
            }

            let tabVC = UITabBarController()
            tabVC.view.tintColor = Colors.flOrange
            tabVC.viewControllers = vcs

            rootNavigationController.pushViewController(tabVC, animated: false)
        }
    }

    let window = UIWindow()

    private let rootNavigationController = CustomNavigationController()
    private let navBarItemsFactory = NavBarItemsFactory()

    // MARK: -

    private func setupNavigationItemsFor(viewController: UIViewController) {
        guard let vc = viewController as? ListViewController else {
            return
        }

        do {
            var leftItems: [NavBarItem] = []

            if rootNavigationController.viewControllers.count > 1 {
                let item = navBarItemsFactory.makeBackItem { [weak self] in
                    _ = self?.rootNavigationController.popViewController(animated: true)
                }

                leftItems.append(item)
            }

            if rootNavigationController.viewControllers.count > 2 {
                let item = navBarItemsFactory.makeHomeItem { [weak self] in
                    self?.tryGoHome()
                }

                leftItems.append(item)
            }

            vc.navBar.leftItems = leftItems
        }

        do {
            var rightItems: [NavBarItem] = []

            do {
                let item = navBarItemsFactory.makeSearchItem { [weak self] in
                    self?.showSearch()
                }

                rightItems.append(item)
            }

            if let urlProvider = viewController as? WebURLProvider {
                let item = navBarItemsFactory.makeShareItemFor { [weak self, weak urlProvider] in
                    if let url = urlProvider?.webURL {
                        self?.share(url: url)
                    }
                }

                rightItems.append(item)
            }

            vc.navBar.rightItems = rightItems
        }

    }

    private func tryGoHome() {
        let alert = Alert()
            .set(title: "Вернуться на главный экран?")
            .add(positiveAction: "Да") { [weak self] in
                _ = self?.rootNavigationController.popToRootViewController(animated: true)
            }
            .set(cancelAction: "Нет") {}

        let alertVC = UIAlertController(alert: alert, preferredStyle: .alert)

        rootNavigationController.present(alertVC, animated: true, completion: nil)
    }

    private func tryShowScanner() {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        if authorizationStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.tryShowScanner()
                }
            }

            return
        }

        if authorizationStatus == .authorized {
            if let vc = BarcodeScannerViewController() {
                vc.modalPresentationStyle = .overFullScreen

                vc.close = { [weak self] code in
                    self?.rootNavigationController.dismiss(animated: true, completion: {
                        code.flatMap({
                            self?.openEditionWith(isbn: $0)
                        })
                    })
                }

                rootNavigationController.present(vc, animated: true, completion: nil)
            } else {
                let alert = Alert()
                    .set(title: "Камера не доступна")
                    .set(cancelAction: "Закрыть") {}

                let alertVC = UIAlertController(alert: alert, preferredStyle: .alert)

                rootNavigationController.present(alertVC, animated: true, completion: nil)
            }
        } else {
            let alert = Alert()
                .set(title: "Требуется доступ к камере")
                .add(positiveAction: "Настройки") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                .set(cancelAction: "Закрыть") {}

            let alertVC = UIAlertController(alert: alert, preferredStyle: .alert)

            rootNavigationController.present(alertVC, animated: true, completion: nil)
        }
    }

    private func showSearch() {
        let vc = MainSearchViewController()

        vc.scanAction = { [weak self] in
            self?.tryShowScanner()
        }

        vc.closeAction = { [weak self] in
            self?.rootNavigationController.popWithFadeAnimation()
        }

        rootNavigationController.pushWithFadeAnimation(viewController: vc)
    }

    private func share(url: URL) {
        let alert = Alert()
            .add(positiveAction: "Поделиться") { [weak self] in
                let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)

                self?.rootNavigationController.present(vc, animated: true, completion: nil)
            }
            .add(positiveAction: "Открыть веб-версию") { [weak self] in
                self?.openWebURL(url: url, entersReaderIfAvailable: false)
            }
            .set(cancelAction: "Отмена") {}

        let alertVC = UIAlertController(alert: alert, preferredStyle: .actionSheet)

        rootNavigationController.present(alertVC, animated: true, completion: nil)
    }

    private func openWebURL(url: URL, entersReaderIfAvailable: Bool) {
        if url.isWebSafe {
            openSafeWebURL(url: url, entersReaderIfAvailable: entersReaderIfAvailable)

            return
        }

        if let fantLabURL = URL.web(url.absoluteString, host: Hosts.portal) {
            openSafeWebURL(url: fantLabURL, entersReaderIfAvailable: entersReaderIfAvailable)

            return
        }

        if let detectedURL = url.absoluteString.detectURLs().first?.0, detectedURL.isWebSafe {
            openSafeWebURL(url: detectedURL, entersReaderIfAvailable: entersReaderIfAvailable)

            return
        }

        let alert = Alert()
            .set(title: "Не удалось перейти по ссылке")
            .set(subtitle: url.absoluteString)
            .add(positiveAction: "Скопировать") {
                UIPasteboard.general.url = url
            }
            .set(cancelAction: "Закрыть") {}

        let alertVC = UIAlertController(alert: alert, preferredStyle: .alert)

        rootNavigationController.present(alertVC, animated: true, completion: nil)
    }

    private func openSafeWebURL(url: URL, entersReaderIfAvailable: Bool) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = entersReaderIfAvailable

        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredControlTintColor = Colors.flBlue

        rootNavigationController.present(vc, animated: true, completion: nil)
    }

    private func openAuthor(id: Int, isOpened: Bool) {
        if isOpened {
            openAuthor(id: id)

            return
        }

        let alert = Alert()
            .set(title: "Страница автора находится в разработке")
            .set(cancelAction: "OK") {}

        let alertVC = UIAlertController(alert: alert, preferredStyle: .alert)

        rootNavigationController.present(alertVC, animated: true, completion: nil)
    }

    // MARK: -

    func openWork(id: Int) {
        let vc = WorkViewController(workId: id)

        rootNavigationController.pushViewController(vc, animated: true)
    }

    func openAuthor(id: Int) {
        let vc = AuthorViewController(authorId: id)

        rootNavigationController.pushViewController(vc, animated: true)
    }

    func openEdition(id: Int) {
        let vc = EditionViewController(editionId: id)

        rootNavigationController.pushViewController(vc, animated: true)
    }

    func openEditionWith(isbn: String) {
        let vc = EditionViewController(isbn: isbn)

        rootNavigationController.pushViewController(vc, animated: true)
    }

    func openUserProfile(id: Int) {
        let vc = UserProfileViewController(userId: id)

        rootNavigationController.pushViewController(vc, animated: true)
    }

    func openWorkAuthors(work: WorkModel) {
        guard !work.authors.isEmpty else {
            return
        }

        if work.authors.count == 1 {
            let author = work.authors[0]

            openAuthor(id: author.id, isOpened: author.isOpened)

            return
        }

        let alert = Alert()

        work.authors.forEach { author in
            alert.add(positiveAction: author.name, perform: { [weak self] in
                self?.openAuthor(id: author.id, isOpened: author.isOpened)
            })
        }

        alert.set(cancelAction: "Закрыть") {}

        let alertVC = UIAlertController(alert: alert, preferredStyle: .actionSheet)

        rootNavigationController.present(alertVC, animated: true, completion: nil)
    }

    func openWorkReviews(workId: Int, reviewsCount: Int) {
        let vc = WorkReviewsViewController(workId: workId, reviewsCount: reviewsCount)

        rootNavigationController.pushViewController(vc, animated: true)
    }

    func openUserReviews(userId: Int, reviewsCount: Int) {
        let vc = WorkReviewsViewController(userId: userId, reviewsCount: reviewsCount)

        rootNavigationController.pushViewController(vc, animated: true)
    }

    func openReview(model: WorkReviewModel, headerMode: WorkReviewHeaderMode) {
        let contentBuilder = WorkReviewContentBuilder(
            headerMode: headerMode,
            showText: false
        )

        contentBuilder.onReviewUserTap = { userId in
            AppRouter.shared.openUserProfile(id: userId)
        }

        contentBuilder.onReviewWorkTap = { workId in
            AppRouter.shared.openWork(id: workId)
        }

        let reviewItems = contentBuilder.makeListItemsFrom(model: model)

        openText(title: "Отзыв",
                 string: model.text,
                 customHeaderListItems: reviewItems,
                 makePhotoURL: nil)
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

        rootNavigationController.pushViewController(vc, animated: true)
    }

    func openAwards(_ awards: [AwardPreviewModel]) {
        let vc = AwardListViewController(awards: awards)

        rootNavigationController.pushViewController(vc, animated: true)
    }

    func openEditionList(_ editionBlocks: [EditionBlockModel]) {
        let vc = EditionListViewController(editionBlocks: editionBlocks)

        rootNavigationController.pushViewController(vc, animated: true)
    }

    func openURL(_ url: URL, entersReaderIfAvailable: Bool = false) {
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

        if let userString = url.path.firstMatch(for: "user\\d+"), let userId = Int(userString.dropFirst(4)) {
            openUserProfile(id: userId)

            return
        }

        openWebURL(url: url, entersReaderIfAvailable: entersReaderIfAvailable)
    }
}

private final class NavBarItemsFactory {
    func makeCameraItem(action: @escaping () -> Void) -> NavBarItem {
        return NavBarItem(
            margin: 8,
            image: UIImage(named: "barcode"),
            contentEdgeInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8),
            size: CGSize(width: 40, height: 40),
            action: action
        )
    }

    func makeBackItem(action: @escaping () -> Void) -> NavBarItem {
        return NavBarItem(
            margin: 0,
            image: UIImage(named: "arrow_left"),
            contentEdgeInsets: UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0),
            size: CGSize(width: 40, height: 40),
            action: action
        )
    }

    func makeHomeItem(action: @escaping () -> Void) -> NavBarItem {
        return NavBarItem(
            margin: 4,
            image: UIImage(named: "home")?.with(orientation: .down),
            contentEdgeInsets: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0),
            size: CGSize(width: 40, height: 40),
            action: action
        )
    }

    func makeSearchItem(action: @escaping () -> Void) -> NavBarItem {
        return NavBarItem(
            margin: 4,
            image: UIImage(named: "search"),
            contentEdgeInsets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12),
            size: CGSize(width: 40, height: 40),
            action: action
        )
    }

    func makeShareItemFor(action: @escaping () -> Void) -> NavBarItem {
        return NavBarItem(
            margin: 8,
            image: UIImage(named: "share"),
            contentEdgeInsets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12),
            size: CGSize(width: 40, height: 40),
            action: action
        )
    }
}
