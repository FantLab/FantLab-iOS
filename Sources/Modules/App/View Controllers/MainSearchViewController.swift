import Foundation
import UIKit
import RxSwift
import RxRelay
import ALLKit
import FLWebAPI
import FLModels
import FLKit
import FLStyle
import FLUIKit
import FLLayoutSpecs
import FLContentBuilders

final class MainSearchViewController: ListViewController<DataStateContentBuilder<SearchResultContentBuilder>> {
    init() {
        super.init(contentBuilder: DataStateContentBuilder(dataContentBuilder: SearchResultContentBuilder()))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public var scanAction: (() -> Void)?
    public var closeAction: (() -> Void)?

    private let searchRelay = PublishRelay<String>()
    private lazy var searchBarView = SearchBarView()

    override func viewDidLoad() {
        super.viewDidLoad()

        topPanelView.subviews.forEach {
            $0.removeFromSuperview()
        }
        topPanelView.addSubview(searchBarView)
        searchBarView.pinEdges(to: topPanelView)

        contentBuilder.dataContentBuilder.onAuthorTap = { [weak self] id in
            self?.openAuthor(id: id)
        }

        contentBuilder.dataContentBuilder.onWorkTap = { [weak self] id in
            self?.openWork(id: id)
        }

        contentBuilder.errorContentBuilder.onRetry = { [weak self] in
            self?.triggerSearch()
        }

        searchBarView.cancelBtn.all_setEventHandler(for: .touchUpInside) { [weak self] in
            self?.closeAction?()
        }

        searchBarView.cameraBtn.all_setEventHandler(for: .touchUpInside) { [weak self] in
            self?.scanAction?()
        }

        searchBarView.textField.all_setEventHandler(for: .editingChanged) { [weak self] in
            self?.triggerSearch()
        }

        Keyboard.frameObservable
            .subscribe(onNext: { [weak self] frame in
                self?.handle(keyboardFrame: frame)
            })
            .disposed(by: disposeBag)

        searchBarView.textField.attributedPlaceholder = "Поиск авторов и произведений".attributed()
            .font(Fonts.system.regular(size: 16))
            .foregroundColor(UIColor.lightGray)
            .make()

        bindUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        searchBarView.textField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        searchBarView.textField.resignFirstResponder()
    }

    // MARK: -

    private func triggerSearch() {
        searchRelay.accept(searchBarView.textField.text ?? "")
    }

    private func bindUI() {
        let loadingObservable: Observable<DataState<SearchResultModel>> = searchRelay.asObservable().map({ _ in DataState<SearchResultModel>.loading })

        let dataObservable: Observable<DataState<SearchResultModel>> = searchRelay.asObservable()
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .flatMapLatest({ searchText -> Observable<DataState<SearchResultModel>> in
                return AppServices.network.perform(request: MainSearchNetworkRequest(searchText: searchText))
                    .map({ DataState<SearchResultModel>.success($0) })
                    .catchError({ error -> Observable<DataState<SearchResultModel>> in
                        return .just(DataState<SearchResultModel>.error(error))
                    })
            })

        Observable.merge(loadingObservable, dataObservable)
            .distinctUntilChanged({ (x, y) -> Bool in
                return x.isLoading && y.isLoading
            })
            .subscribe(onNext: { [weak self] viewState in
                self?.apply(viewState: viewState)
            })
            .disposed(by: disposeBag)
    }

    private func handle(keyboardFrame: CGRect) {
        additionalSafeAreaInsets.bottom = max(0, keyboardFrame.intersection(view.absoluteFrame).height)
    }

    // MARK: -

    private func openAuthor(id: Int) {
        AppRouter.shared.openAuthor(id: id)
    }

    private func openWork(id: Int) {
        AppRouter.shared.openWork(id: id)
    }
}

private final class SearchBarView: UIView {
    private let backgroundView = UIView()
    let textField = UITextField()
    let cameraBtn = UIButton(type: .system)
    let cancelBtn = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(cancelBtn)
        addSubview(backgroundView)
        backgroundView.addSubview(cameraBtn)
        backgroundView.addSubview(textField)

        do {
            backgroundView.backgroundColor = UIColor.white
            backgroundView.layer.cornerRadius = 16
            backgroundView.pin(.centerY).to(self).equal()
            backgroundView.pin(.height).const(32).equal()
            backgroundView.pin(.left).to(self).const(6).equal()
            backgroundView.pin(.right).to(cancelBtn, .left).const(-8).equal()
        }

        do {
            cancelBtn.setAttributedTitle("Отмена".attributed()
                .font(Fonts.system.regular(size: 17))
                .foregroundColor(UIColor.white)
                .make(), for: .normal)
            cancelBtn.pin(.right).to(self, .right).const(-10).equal()
            cancelBtn.pin(.centerY).to(self).equal()
            cancelBtn.setContentHuggingPriority(.required, for: .horizontal)
            cancelBtn.setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        do {
            cameraBtn.tintColor = Colors.fantasticBlue
            cameraBtn.setImage(UIImage(named: "barcode")?.withRenderingMode(.alwaysTemplate), for: [])
            cameraBtn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 4)
            cameraBtn.pinEdges(to: backgroundView, left: 3, right: .nan)
            cameraBtn.pin(.width).to(cameraBtn, .height).equal()
        }

        do {
            textField.tintColor = Colors.fantasticBlue
            textField.font = Fonts.system.regular(size: 16)
            textField.clearButtonMode = .whileEditing
            textField.pinEdges(to: backgroundView, left: .nan)
            textField.pin(.left).to(cameraBtn, .right).const(4).equal()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
