import Foundation
import UIKit
import SafariServices
import AVFoundation
import RxSwift
import ALLKit
import FLModels
import FLContentBuilders
import FLStyle
import FLUIKit
import FLWebAPI
import FLKit
import FLLayoutSpecs

final class AppRouter {
    static let shared = AppRouter()

    let window = UIWindow()

    private let rootNavigationController = CustomNavigationController()
    private let navBarItemsFactory = NavBarItemsFactory()
    private let disposeBag = DisposeBag()
    private let backgroundImageDisplaySubject = PublishSubject<URL?>()

    private init() {
        do {
            backgroundImageDisplaySubject
                .filter({ $0 != nil })
                .distinctUntilChanged()
                .subscribe(onNext: { _ in
                    AppAnalytics.logScrollToBackgroundImage()
                })
                .disposed(by: disposeBag)
        }

        do {
            window.rootViewController = makeBackgroundImageWith(content: rootNavigationController)

            rootNavigationController.pushViewController(makeTabVC(), animated: false)

            rootNavigationController.willShowVC = { [weak self] vc in
                self?.setupNavigationItemsFor(viewController: vc)
            }

            window.tintColor = Colors.fantasticBlue
            window.makeKeyAndVisible()
        }
    }

    // MARK: -

    private func makeBackgroundImageWith(content vc: UIViewController) -> UIViewController {
        let imageVC = ImageBackgroundViewController()
        imageVC.add(child: vc) {
            imageVC.contentView.addSubview(vc.view)
            vc.view.pinEdges(to: imageVC.contentView)
        }

        imageVC.onImageDisplay = { [weak self] url in
            self?.backgroundImageDisplaySubject.onNext(url)
        }

        return imageVC
    }

    private func makeTabVC() -> UIViewController {
        var vcs: [UIViewController] = []

        do {
            let vc = NewsViewController()
            vc.title = "Новости"
            vc.tabBarItem = UITabBarItem(title: "Новости", image: UIImage(named: "news"), tag: 1)
            setupNavigationItemsForTab(viewController: vc)
            vcs.append(vc)
        }

        do {
            let vc = MyBooksViewController()
            vc.title = "Мои книги"
            vc.tabBarItem = UITabBarItem(title: "Мои книги", image: UIImage(named: "books"), tag: 2)
            setupNavigationItemsForTab(viewController: vc)
            vcs.append(vc)
        }

        do {
            let vc = FreshReviewsViewController()
            vc.title = "Отзывы"
            vc.tabBarItem = UITabBarItem(title: "Отзывы", image: UIImage(named: "reviews"), tag: 3)
            setupNavigationItemsForTab(viewController: vc)
            vcs.append(vc)
        }

        let tabVC = UITabBarController()
        tabVC.view.tintColor = Colors.darkOrange
        tabVC.tabBar.isTranslucent = false
        tabVC.viewControllers = vcs

        return tabVC
    }

    private func setupNavigationItemsForTab(viewController: UIViewController) {
        guard let vc = viewController as? NavBarProvider else {
            return
        }

        let cameraItem = navBarItemsFactory.makeCameraItem { [weak self] in
            self?.tryShowScanner(from: .mainScreen)
        }

        let searchItem = navBarItemsFactory.makeSearchItem { [weak self] in
            self?.showSearch()
        }

        vc.navBar.leftItems = [cameraItem]
        vc.navBar.rightItems = [searchItem]
    }

    private func setupNavigationItemsFor(viewController: UIViewController) {
        guard let vc = viewController as? NavBarProvider else {
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

            leftItems += (vc as? NavBarItemsProvider)?.leftItems ?? []

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

            rightItems += (vc as? NavBarItemsProvider)?.rightItems ?? []

            vc.navBar.rightItems = rightItems
        }
    }

    private func show(alert: Alert, preferredStyle: UIAlertController.Style) {
        let vc = UIAlertController(alert: alert, preferredStyle: preferredStyle)

        rootNavigationController.present(vc, animated: true, completion: nil)
    }

    private func tryGoHome() {
        let alert = Alert()
            .set(title: "Вернуться на главный экран?")
            .add(positiveAction: "Да") { [weak self] in
                AppAnalytics.logGoHomeConfirmTap()

                _ = self?.rootNavigationController.popToRootViewController(animated: true)
            }
            .set(cancelAction: "Нет") {}

        show(alert: alert, preferredStyle: .alert)
    }

    private func tryShowScanner(from source: AppAnalytics.BarcodeScannerSource) {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        if authorizationStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.tryShowScanner(from: source)
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

                rootNavigationController.present(vc, animated: true) {
                    AppAnalytics.logOpenBarcodeScanner(from: source)
                }
            } else {
                let alert = Alert()
                    .set(title: "Камера не доступна")
                    .set(cancelAction: "Закрыть") {}

                show(alert: alert, preferredStyle: .alert)
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

            show(alert: alert, preferredStyle: .alert)
        }
    }

    private func showSearch() {
        let vc = MainSearchViewController()

        vc.scanAction = { [weak self] in
            self?.tryShowScanner(from: .searchScreen)
        }

        vc.closeAction = { [weak self] in
            self?.rootNavigationController.popWithFadeAnimation()
        }

        rootNavigationController.pushWithFadeAnimation(viewController: vc)
    }

    private func share(url: URL) {
        let alert = Alert()
            .add(positiveAction: "Поделиться") { [weak self] in
                AppAnalytics.logShareButtonTap(url: url)

                let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)

                self?.rootNavigationController.present(vc, animated: true, completion: nil)
            }
            .add(positiveAction: "Открыть веб-версию") { [weak self] in
                AppAnalytics.logOpenWebVersionButtonTap(url: url)

                self?.openWebURL(url: url, entersReaderIfAvailable: false)
            }
            .set(cancelAction: "Отмена") {}

        show(alert: alert, preferredStyle: .actionSheet)
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

        show(alert: alert, preferredStyle: .alert)
    }

    private func openSafeWebURL(url: URL, entersReaderIfAvailable: Bool) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = entersReaderIfAvailable

        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredControlTintColor = Colors.fantasticBlue

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

        show(alert: alert, preferredStyle: .alert)
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

    func openAuthorWebsites(_ author: AuthorModel) {
        guard !author.sites.isEmpty else {
            return
        }

        if author.sites.count == 1 {
            openURL(author.sites[0].link)

            return
        }

        let alert = Alert()

        author.sites.forEach { site in
            alert.add(positiveAction: site.title.capitalizedFirstLetter(), perform: { [weak self] in
                self?.openURL(site.link)
            })
        }

        alert.set(cancelAction: "Закрыть") {}

        let alertVC = UIAlertController(alert: alert, preferredStyle: .actionSheet)

        rootNavigationController.present(alertVC, animated: true, completion: nil)
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

        show(alert: alert, preferredStyle: .actionSheet)
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

    func openNews(model: NewsModel) {
        let headerItem = ListItem(
            id: "news_header",
            layoutSpec: NewsHeaderLayoutSpec(model: model)
        )

        openText(title: "Новость", string: model.text, customHeaderListItems: [headerItem], makePhotoURL: nil)
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
            contentEdgeInsets: UIEdgeInsets(top: 10, left: 6, bottom: 10, right: 8),
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
            margin: 4,
            image: UIImage(named: "share"),
            contentEdgeInsets: UIEdgeInsets(top: 6, left: 10, bottom: 10, right: 10),
            size: CGSize(width: 40, height: 40),
            action: action
        )
    }
}
