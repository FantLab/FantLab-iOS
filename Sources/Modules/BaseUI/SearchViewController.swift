import Foundation
import UIKit
import RxSwift
import ALLKit
import FantLabStyle

open class SearchViewController: BaseViewController {
    private let searchSubject = PublishSubject<String>()

    deinit {
        searchSubject.onCompleted()
    }

    public final var searchTextObservable: Observable<String> {
        return searchSubject
    }

    public var scanAction: (() -> Void)?
    public var closeAction: (() -> Void)?

    public let adapter = CollectionViewAdapter()

    private var searchField: UITextField?

    open override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        guard !view.bounds.isEmpty else {
            return
        }

        adapter.set(sizeConstraints: SizeConstraints(width: view.bounds.width, height: .nan))
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        searchField?.becomeFirstResponder()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        searchField?.resignFirstResponder()
    }

    // MARK: -

    public final func triggerSearch() {
        searchSubject.onNext(searchField?.text ?? "")
    }

    public var placeholderText: String = "" {
        didSet {
            searchField?.placeholder = placeholderText
        }
    }

    // MARK: -

    private func setupUI() {
        let statusBarView = UIView()
        statusBarView.backgroundColor = Colors.flBlue
        view.addSubview(statusBarView)
        statusBarView.pinEdges(to: view, bottom: .nan)
        statusBarView.pin(.bottom).to(view.safeAreaLayoutGuide, .top).equal()

        let searchBarView = UIView()
        searchBarView.backgroundColor = Colors.flBlue
        view.addSubview(searchBarView)
        searchBarView.pin(.left).to(view).equal()
        searchBarView.pin(.right).to(view).equal()
        searchBarView.pin(.top).to(view.safeAreaLayoutGuide).equal()
        searchBarView.pin(.height).const(44).equal()

        let cancelBtn = UIButton(type: .system)
        cancelBtn.setAttributedTitle("Отмена".attributed().font(Fonts.system.regular(size: 17)).foregroundColor(UIColor.white).make(), for: .normal)
        cancelBtn.all_setEventHandler(for: .touchUpInside) { [weak self] in
            self?.closeAction?()
        }
        searchBarView.addSubview(cancelBtn)
        cancelBtn.pin(.right).to(searchBarView, .right).const(-10).equal()
        cancelBtn.pin(.centerY).to(searchBarView).equal()
        cancelBtn.setContentHuggingPriority(.required, for: .horizontal)
        cancelBtn.setContentCompressionResistancePriority(.required, for: .horizontal)

        let textBackgroundView = UIView()
        textBackgroundView.backgroundColor = UIColor.white
        textBackgroundView.layer.cornerRadius = 16
        searchBarView.addSubview(textBackgroundView)
        textBackgroundView.pin(.centerY).to(searchBarView).equal()
        textBackgroundView.pin(.height).const(32).equal()
        textBackgroundView.pin(.left).to(searchBarView).const(6).equal()
        textBackgroundView.pin(.right).to(cancelBtn, .left).const(-8).equal()

        let cameraBtn = UIButton(type: .system)
        cameraBtn.tintColor = Colors.flBlue
        cameraBtn.setImage(UIImage(named: "barcode")?.withRenderingMode(.alwaysTemplate), for: [])
        cameraBtn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 4)
        cameraBtn.all_setEventHandler(for: .touchUpInside) { [weak self] in
            self?.scanAction?()
        }
        textBackgroundView.addSubview(cameraBtn)
        cameraBtn.pinEdges(to: textBackgroundView, left: 4, right: .nan)
        cameraBtn.pin(.width).to(cameraBtn, .height).equal()

        let textField = UITextField()
        textField.font = Fonts.system.regular(size: 16)
        textField.clearButtonMode = .whileEditing
        textField.all_setEventHandler(for: .editingChanged) { [weak self] in
            self?.triggerSearch()
        }
        textBackgroundView.addSubview(textField)
        textField.pinEdges(to: textBackgroundView, left: .nan)
        textField.pin(.left).to(cameraBtn, .right).const(4).equal()
        searchField = textField

        adapter.collectionView.backgroundColor = UIColor.white
        adapter.collectionView.alwaysBounceVertical = true
        adapter.collectionView.contentInset.bottom = UIScreen.main.bounds.size.height
        adapter.collectionView.showsVerticalScrollIndicator = false
        view.addSubview(adapter.collectionView)
        adapter.collectionView.pinEdges(to: view, top: .nan)
        adapter.collectionView.pin(.top).to(searchBarView, .bottom).equal()
    }
}
