import Foundation
import UIKit
import RxSwift
import ALLKit
import FLStyle
import FLKit

open class ListViewController<BuilderType: ListContentBuilder>: BaseViewController, NavBarProvider {
    public let topPanelView = UIView()
    public let contentBuilder: BuilderType
    private let adapter = CollectionViewAdapter()
    private let viewStateSubject = ReplaySubject<BuilderType.ModelType>.create(bufferSize: 1)
    private let scrollSubject = PublishSubject<CGFloat>()
    private let statusBarView = UIView()
    private let navBarView = NavBarView()
    private var isBackgroundImageSet: Bool = false

    private lazy var imageVC: ImageBackgroundViewController? = parentVC()

    public init(contentBuilder: BuilderType) {
        self.contentBuilder = contentBuilder

        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    deinit {
        viewStateSubject.onCompleted()
        scrollSubject.onCompleted()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindUI()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.bringSubviewToFront(statusBarView)
        view.bringSubviewToFront(topPanelView)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let bounds = adapter.collectionView.bounds

        guard !bounds.isEmpty else {
            return
        }

        adapter.set(sizeConstraints: sizeConstraintsFromView(bounds: bounds))
    }

    // MARK: -

    open func sizeConstraintsFromView(bounds: CGRect) -> SizeConstraints {
        return SizeConstraints(width: bounds.width, height: .nan)
    }

    open override var title: String? {
        didSet {
            navBar.set(title: title?.attributed()
                .font(Fonts.system.bold(size: 18))
                .alignment(.center)
                .foregroundColor(UIColor.white).make())
        }
    }

    public var navBar: NavBar {
        return navBarView
    }

    public var scrollView: UIScrollView {
        return adapter.collectionView
    }

    public var scrollObservable: Observable<CGFloat> {
        return scrollSubject
    }

    public func apply(viewState: BuilderType.ModelType) {
        viewStateSubject.onNext(viewState)
    }

    public final func setupBackgroundImageWith(urlObservable: Observable<URL?>) {
        guard !isBackgroundImageSet else {
            return
        }

        isBackgroundImageSet = true

        scrollObservable
            .subscribe(onNext: { [weak self] offset in
                self?.imageVC?.moveTo(position: max(0, -offset) / 100)
            })
            .disposed(by: disposeBag)

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
        statusBarView.backgroundColor = Colors.fantasticBlue
        view.addSubview(statusBarView)
        statusBarView.pinEdges(to: view, bottom: .nan)
        statusBarView.pin(.bottom).to(view.safeAreaLayoutGuide, .top).equal()

        topPanelView.backgroundColor = Colors.fantasticBlue
        topPanelView.tintColor = UIColor.white
        view.addSubview(topPanelView)
        topPanelView.pin(.height).const(44).equal()
        topPanelView.pin(.top).to(statusBarView, .bottom).equal()
        topPanelView.pin(.left).to(view).equal()
        topPanelView.pin(.right).to(view).equal()

        adapter.collectionView.backgroundColor = UIColor.white
        adapter.collectionView.alwaysBounceVertical = true
        view.addSubview(adapter.collectionView)
        adapter.collectionView.pinEdges(to: view, top: .nan)
        adapter.collectionView.pin(.top).to(topPanelView, .bottom).equal()

        navBarView.tintColor = UIColor.white
        topPanelView.addSubview(navBarView)
        navBarView.pinEdges(to: topPanelView)
    }

    private func bindUI() {
        adapter.scrollEvents.didScroll = { [weak self] scrollView in
            self?.scrollSubject.onNext(scrollView.contentOffset.y)
        }

        viewStateSubject
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ [weak self] state -> [ListItem] in
                self?.contentBuilder.makeListItemsFrom(model: state) ?? []
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.adapter.set(items: items)
            })
            .disposed(by: disposeBag)
    }
}
