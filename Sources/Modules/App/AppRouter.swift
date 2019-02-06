import Foundation
import UIKit
import SafariServices
import AVFoundation
import RxSwift
import ALLKit
import FantLabModels
import FantLabLayoutSpecs
import FantLabStyle
import FantLabBaseUI
import FantLabWebAPI
import FantLabUtils

private final class RootNavigationController: UINavigationController, UINavigationControllerDelegate {
    var onSearch: (() -> Void)?
    var onShare: ((URL) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        Appearance.setup(navigationBar: navigationBar)
        delegate = self
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        let searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))

        if viewController is WebURLProvider {
            let shareItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))

            viewController.navigationItem.rightBarButtonItems = [searchItem, shareItem]
        } else {
            viewController.navigationItem.rightBarButtonItems = [searchItem]
        }
    }

    @objc
    private func search() {
        onSearch?()
    }

    @objc
    private func share() {
        guard let webURLProvider = topViewController as? WebURLProvider, let url = webURLProvider.webURL else {
            return
        }

        onShare?(url)
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
            window.makeKeyAndVisible()

            window.tintColor = Colors.flBlue
        }

        navigationController.onSearch = { [weak self] in
            self?.presentSearch()
        }

        navigationController.onShare = { [weak self] url in
            self?.share(url: url)
        }

        do {
            let startVC = StartViewController()
            startVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(showScannerTapped))

            navigationController.pushViewController(startVC, animated: false)
        }
    }

    let window = UIWindow()

    private let navigationController = RootNavigationController()
    private lazy var searchVC = SearchViewController()

    // MARK: -

    @objc
    private func showScannerTapped() {
        tryShowScanner()
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

    private func presentSearch() {
        searchVC.modalPresentationStyle = .overFullScreen
        searchVC.modalTransitionStyle = .crossDissolve

        navigationController.present(searchVC, animated: true, completion: nil)
    }

    private func share(url: URL) {
        let alert = Alert()
            .add(positiveAction: "Поделиться") { [weak self] in
                let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)

                self?.navigationController.present(vc, animated: true, completion: nil)
            }
            .add(positiveAction: "Открыть веб-версию") { [weak self] in
                self?.openWebURL(url: url)
            }
            .set(cancelAction: "Отмена") {}

        let alertVC = UIAlertController(alert: alert, preferredStyle: .actionSheet)

        navigationController.present(alertVC, animated: true, completion: nil)
    }

    private func openWebURL(url: URL) {
        if url.host != nil && (url.scheme == "http" || url.scheme == "https") {
            openSafeWebURL(url: url)

            return
        }

        if let fantLabURL = URL.from(string: url.absoluteString, defaultHost: Hosts.portal, defaultScheme: "https") {
            openSafeWebURL(url: fantLabURL)

            return
        }

        let alert = Alert()
            .set(title: url.absoluteString)
            .add(positiveAction: "Скопировать") {
                UIPasteboard.general.url = url
            }
            .set(cancelAction: "Закрыть") {}

        let alertVC = UIAlertController(alert: alert, preferredStyle: .alert)

        navigationController.present(alertVC, animated: true, completion: nil)
    }

    private func openSafeWebURL(url: URL) {
        let vc = SFSafariViewController(url: url)
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

        openWebURL(url: url)
    }
}
