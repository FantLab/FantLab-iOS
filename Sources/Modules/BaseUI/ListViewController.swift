import Foundation
import UIKit
import RxSwift
import ALLKit
import FantLabStyle

open class ListViewController: BaseViewController {
    public let adapter = CollectionViewAdapter()

    let navBarView = NavBarView()

    public var navBar: NavBar {
        return navBarView
    }

    private lazy var imageVC: ImageBackgroundViewController? = parentVC()

    open override var title: String? {
        didSet {
            navBar.set(title: title?.attributed().font(Fonts.system.bold(size: 18)).foregroundColor(UIColor.white).make())
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.bringSubviewToFront(navBarView)
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        guard !view.bounds.isEmpty else {
            return
        }

        adapter.set(sizeConstraints: SizeConstraints(width: view.bounds.width, height: .nan))
    }

    // MARK: -

    private func updateBackgroundImageVisibility() {
        let offset = adapter.collectionView.contentOffset.y

        imageVC?.moveTo(position: max(0, -offset) / 100)
    }

    public final func setupBackgroundImageWith(urlObservable: Observable<URL?>) {
        adapter.scrollEvents.didScroll = { [weak self] _ in
            self?.updateBackgroundImageVisibility()
        }

        Observable.combineLatest(viewActive, urlObservable)
            .map({ (viewActive, url) -> URL? in
                return viewActive ? url : nil
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] imageURL in
                self?.imageVC?.imageURL = imageURL
            })
            .disposed(by: disposeBag)
    }

    // MARK: -

    private func setupUI() {
        let statusBarView = UIView()
        statusBarView.backgroundColor = Colors.flBlue
        view.addSubview(statusBarView)
        statusBarView.pinEdges(to: view, bottom: .nan)
        statusBarView.pin(.bottom).to(view.safeAreaLayoutGuide, .top).equal()

        navBarView.backgroundColor = Colors.flBlue
        navBarView.tintColor = UIColor.white
        view.addSubview(navBarView)
        navBarView.pin(.top).to(statusBarView, .bottom).equal()
        navBarView.pin(.left).to(view).equal()
        navBarView.pin(.right).to(view).equal()

        adapter.collectionView.backgroundColor = UIColor.white
        adapter.collectionView.alwaysBounceVertical = true
        view.addSubview(adapter.collectionView)
        adapter.collectionView.pinEdges(to: view, top: .nan)
        adapter.collectionView.pin(.top).to(navBarView, .bottom).equal()
    }
}
