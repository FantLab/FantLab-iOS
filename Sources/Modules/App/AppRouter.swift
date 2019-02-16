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

private final class RootNavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    var backAction: (() -> Void)?
    var goHomeAction: (() -> Void)?
    var searchAction: (() -> Void)?
    var shareAction: ((URL) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBarHidden(true, animated: false)

        view.backgroundColor = UIColor.white
        Appearance.setup(navigationBar: navigationBar)
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }

    // MARK: -

    func popWithFadeAnimation() {
        view.layer.add(makeFadeTransition(), forKey: nil)
        _ = popViewController(animated: false)
    }

    func pushWithFadeAnimation(viewController: UIViewController) {
        view.layer.add(makeFadeTransition(), forKey: nil)
        pushViewController(viewController, animated: false)
    }

    private func makeFadeTransition() -> CATransition {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .fade
        return transition
    }

    // MARK: -

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === interactivePopGestureRecognizer else {
            return false
        }

        return viewControllers.count > 1
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let vc = viewController as? ListViewController else {
            return
        }

        do {
            var leftItems: [NavBarItem] = []

            if viewControllers.count > 1 {
                leftItems.append(makeBackItem())
            }

            if viewControllers.count > 2 {
                leftItems.append(makeHomeItem())
            }

            if !leftItems.isEmpty {
                vc.navBar.leftItems = leftItems
            }
        }

        do {
            var rightItems: [NavBarItem] = []

            do {
                let searchItem = makeSearchItem()

                rightItems.append(searchItem)
            }

            if let urlProvider = viewController as? WebURLProvider {
                let shareItem = makeShareItemFor(urlProvider: urlProvider)

                rightItems.append(shareItem)
            }

            vc.navBar.rightItems = rightItems
        }
    }

    // MARK: -

    private func makeBackItem() -> NavBarItem {
        return NavBarItem(margin: 0) { [weak self] in
            let btn = UIButton(type: .system)
            btn.setImage(UIImage(named: "arrow_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            btn.pin(.width).const(40).equal()
            btn.pin(.height).const(40).equal()
            btn.all_setEventHandler(for: .touchUpInside, {
                self?.backAction?()
            })
            return btn
        }
    }

    private func makeHomeItem() -> NavBarItem {
        return NavBarItem(margin: 4) { [weak self] in
            let btn = UIButton(type: .system)
            btn.setImage(UIImage(named: "home")?.withRenderingMode(.alwaysTemplate).with(orientation: .down), for: .normal)
            btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
            btn.pin(.width).const(40).equal()
            btn.pin(.height).const(40).equal()
            btn.all_setEventHandler(for: .touchUpInside, {
                self?.goHomeAction?()
            })
            return btn
        }
    }

    private func makeSearchItem() -> NavBarItem {
        return NavBarItem(margin: 4) { [weak self] in
            let btn = UIButton(type: .system)
            btn.setImage(UIImage(named: "search")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
            btn.pin(.width).const(40).equal()
            btn.pin(.height).const(40).equal()
            btn.all_setEventHandler(for: .touchUpInside, {
                self?.searchAction?()
            })
            return btn
        }
    }

    private func makeShareItemFor(urlProvider: WebURLProvider) -> NavBarItem {
        return NavBarItem(margin: 8) { [weak self, weak urlProvider] in
            let btn = UIButton(type: .system)
            btn.setImage(UIImage(named: "share")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            btn.pin(.width).const(40).equal()
            btn.pin(.height).const(40).equal()
            btn.all_setEventHandler(for: .touchUpInside, {
                if let url = urlProvider?.webURL {
                    self?.shareAction?(url)
                }
            })
            return btn
        }
    }
}

final class AppRouter {
    static let shared = AppRouter()

    private init() {
        do {
            let imageVC = ImageBackgroundViewController()
            imageVC.addChild(navigationController)
            imageVC.contentView.addSubview(navigationController.view)
            navigationController.view.pinEdges(to: imageVC.view)
            navigationController.didMove(toParent: imageVC)
            window.rootViewController = imageVC
        }

        do {
            window.tintColor = Colors.flBlue
            window.makeKeyAndVisible()
        }

        do {
            navigationController.backAction = { [weak self] in
                _ = self?.navigationController.popViewController(animated: true)
            }

            navigationController.goHomeAction = { [weak self] in
                self?.tryGoHome()
            }

            navigationController.searchAction = { [weak self] in
                self?.showSearch()
            }

            navigationController.shareAction = { [weak self] url in
                self?.share(url: url)
            }
        }

        do {
            let startVC = StartViewController()

            do {
                let cameraItem = NavBarItem(margin: 8) { [weak self] in
                    let btn = UIButton(type: .system)
                    btn.setImage(UIImage(named: "camera")?.withRenderingMode(.alwaysTemplate), for: .normal)
                    btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
                    btn.pin(.width).const(40).equal()
                    btn.pin(.height).const(40).equal()
                    btn.all_setEventHandler(for: .touchUpInside, {
                        self?.tryShowScanner()
                    })
                    return btn
                }

                startVC.navBar.leftItems = [cameraItem]
            }

            navigationController.pushViewController(startVC, animated: false)
        }
    }

    let window = UIWindow()

    private let navigationController = RootNavigationController()

    // MARK: -

    private func tryGoHome() {
        let alert = Alert()
            .set(title: "Вернуться на главный экран?")
            .add(positiveAction: "Да") { [weak self] in
                _ = self?.navigationController.popToRootViewController(animated: true)
            }
            .set(cancelAction: "Нет") {}

        let alertVC = UIAlertController(alert: alert, preferredStyle: .alert)

        navigationController.present(alertVC, animated: true, completion: nil)
    }

    private func tryShowScanner() {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        if authorizationStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
                self?.tryShowScanner()
            }

            return
        }

        if authorizationStatus == .authorized {
            if let vc = BarcodeScannerViewController() {
                vc.modalPresentationStyle = .overFullScreen

                vc.close = { [weak self] code in
                    self?.navigationController.dismiss(animated: true, completion: {
                        code.flatMap({
                            self?.openEditionWith(isbn: $0)
                        })
                    })
                }

                navigationController.present(vc, animated: true, completion: nil)
            } else {
                let alert = Alert()
                    .set(title: "Камера не доступна")
                    .set(cancelAction: "Закрыть") {}

                let alertVC = UIAlertController(alert: alert, preferredStyle: .alert)

                navigationController.present(alertVC, animated: true, completion: nil)
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

            navigationController.present(alertVC, animated: true, completion: nil)
        }
    }

    private func showSearch() {
        let vc = MainSearchViewController()

        vc.closeAction = { [weak self] in
            self?.navigationController.popWithFadeAnimation()
        }

        navigationController.pushWithFadeAnimation(viewController: vc)
    }

    private func share(url: URL) {
        let alert = Alert()
            .add(positiveAction: "Поделиться") { [weak self] in
                let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)

                self?.navigationController.present(vc, animated: true, completion: nil)
            }
            .add(positiveAction: "Открыть веб-версию") { [weak self] in
                self?.openWebURL(url: url, entersReaderIfAvailable: false)
            }
            .set(cancelAction: "Отмена") {}

        let alertVC = UIAlertController(alert: alert, preferredStyle: .actionSheet)

        navigationController.present(alertVC, animated: true, completion: nil)
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

        navigationController.present(alertVC, animated: true, completion: nil)
    }

    private func openSafeWebURL(url: URL, entersReaderIfAvailable: Bool) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = entersReaderIfAvailable

        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredControlTintColor = Colors.flBlue

        navigationController.present(vc, animated: true, completion: nil)
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

        navigationController.present(alertVC, animated: true, completion: nil)
    }

    // MARK: -

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

    func openEditionWith(isbn: String) {
        let vc = EditionViewController(isbn: isbn)

        navigationController.pushViewController(vc, animated: true)
    }

    func openUserProfile(id: Int) {
        let vc = UserProfileViewController(userId: id)

        navigationController.pushViewController(vc, animated: true)
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

        navigationController.present(alertVC, animated: true, completion: nil)
    }

    func openWorkReviews(workId: Int, reviewsCount: Int) {
        let vc = WorkReviewsViewController(workId: workId, reviewsCount: reviewsCount)

        navigationController.pushViewController(vc, animated: true)
    }

    func openUserReviews(userId: Int, reviewsCount: Int) {
        let vc = WorkReviewsViewController(userId: userId, reviewsCount: reviewsCount)

        navigationController.pushViewController(vc, animated: true)
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
