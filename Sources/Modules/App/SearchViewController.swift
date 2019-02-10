import Foundation
import UIKit
import Vision
import RxSwift
import ALLKit
import FantLabWebAPI
import FantLabModels
import FantLabUtils
import FantLabStyle
import FantLabBaseUI
import FantLabLayoutSpecs
import FantLabContentBuilders

final class SearchViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let searchSubject = PublishSubject<String>()
    private let listVC = ListViewController()
    private let contentBuilder = DataStateContentBuilder(dataContentBuilder: SearchResultContentBuilder())

    deinit {
        searchSubject.onCompleted()
    }

    private var searchField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        contentBuilder.dataContentBuilder.onAuthorTap = { [weak self] id in
            self?.openAuthor(id: id)
        }

        contentBuilder.dataContentBuilder.onWorkTap = { [weak self] id in
            self?.openWork(id: id)
        }

        contentBuilder.errorContentBuilder.onRetry = { [weak self] in
            self?.searchSubject.onNext(self?.searchField?.text ?? "")
        }

        setupUI()
        setupStateMapping()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        searchField?.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        searchField?.resignFirstResponder()
    }

    // MARK: -

    private func setupUI() {
        let statusBar = UIView()
        statusBar.backgroundColor = Colors.flBlue
        view.addSubview(statusBar)
        statusBar.pinEdges(to: view, bottom: .nan)
        statusBar.pin(.bottom).to(view.safeAreaLayoutGuide, .top).equal()

        let searchBar = UIView()
        searchBar.backgroundColor = Colors.flBlue
        view.addSubview(searchBar)
        searchBar.pin(.left).to(view).equal()
        searchBar.pin(.right).to(view).equal()
        searchBar.pin(.top).to(view.safeAreaLayoutGuide).equal()
        searchBar.pin(.height).const(44).equal()

        let cancelBtn = UIButton(type: .system)
        cancelBtn.setAttributedTitle("Отмена".attributed().font(Fonts.system.regular(size: 17)).foregroundColor(UIColor.white).make(), for: .normal)
        cancelBtn.all_setEventHandler(for: .touchUpInside) { [weak self] in
            self?.dismiss(animated: true)
        }
        searchBar.addSubview(cancelBtn)
        cancelBtn.pin(.right).to(searchBar, .right).const(-10).equal()
        cancelBtn.pin(.centerY).to(searchBar).equal()
        cancelBtn.setContentHuggingPriority(.required, for: .horizontal)
        cancelBtn.setContentCompressionResistancePriority(.required, for: .horizontal)

        let textBackgroundView = UIView()
        textBackgroundView.backgroundColor = UIColor.white
        textBackgroundView.layer.cornerRadius = 16
        searchBar.addSubview(textBackgroundView)
        textBackgroundView.pinEdges(to: searchBar, top: 6, left: 6, bottom: 6, right: .nan)
        textBackgroundView.pin(.right).to(cancelBtn, .left).const(-8).equal()

        let textField = UITextField()
        textField.font = Fonts.system.regular(size: 16)
        textField.placeholder = "Поиск авторов и произведений"
        textField.clearButtonMode = .whileEditing
        textField.all_setEventHandler(for: UIControl.Event.editingChanged) { [weak self] in
            self?.searchSubject.onNext(self?.searchField?.text ?? "")
        }
        textBackgroundView.addSubview(textField)
        textField.pinEdges(to: textBackgroundView, left: 12)
        searchField = textField

        do {
            addChild(listVC)
            view.addSubview(listVC.view)
            let bottomInset = UIScreen.main.bounds.height / 2
            listVC.adapter.collectionView.contentInset.bottom = bottomInset
            listVC.adapter.collectionView.scrollIndicatorInsets.bottom = bottomInset
            listVC.view.pinEdges(to: view, top: .nan)
            listVC.view.pin(.top).to(searchBar, .bottom).equal()
            listVC.didMove(toParent: self)
        }
    }

    private func setupStateMapping() {
        let loadingObservable: Observable<DataState<MainSearchResult>> = searchSubject.map({ _ in DataState<MainSearchResult>.loading })

        let dataObservable: Observable<DataState<MainSearchResult>> = searchSubject
            .debounce(0.5, scheduler: MainScheduler.instance)
            .flatMapLatest({ searchText -> Observable<DataState<MainSearchResult>> in
                return NetworkClient.shared.perform(request: MainSearchNetworkRequest(searchText: searchText))
                    .map({ DataState<MainSearchResult>.idle($0) })
                    .catchError({ error -> Observable<DataState<MainSearchResult>> in
                        return .just(DataState<MainSearchResult>.error(error))
                    })
            })

        Observable.merge(loadingObservable, dataObservable)
            .distinctUntilChanged({ (x, y) -> Bool in
                return x.isLoading && y.isLoading
            })
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ [weak self] state -> [ListItem] in
                let dataModel = state.map({ result -> SearchResultContentModel in
                    (result.authors, result.works)
                })

                return self?.contentBuilder.makeListItemsFrom(model: dataModel) ?? []
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] listItems in
                self?.listVC.adapter.set(items: listItems)
            })
            .disposed(by: disposeBag)
    }

    // MARK: -

    private func openAuthor(id: Int) {
        AppRouter.shared.openAuthor(id: id)

        dismiss(animated: true)
    }

    private func openWork(id: Int) {
        AppRouter.shared.openWork(id: id)

        dismiss(animated: true)
    }
}
