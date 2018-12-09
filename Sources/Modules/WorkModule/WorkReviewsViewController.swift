import Foundation
import UIKit
import RxSwift
import ALLKit
import FantLabUtils
import FantLabStyle
import FantLabSharedUI
import FantLabTextUI
import FantLabModels

final class WorkReviewsViewController: ListViewController {
    private let disposeBag = DisposeBag()
    private let interactor: WorkReviewsInteractor
    private let router: WorkModuleRouter

    init(workId: Int, router: WorkModuleRouter) {
        self.interactor = WorkReviewsInteractor(workId: workId)
        self.router = router

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private let sortSelectionControl = UISegmentedControl(items: ["Оценка", "Дата", "Рейтинг"])

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Отзывы"

        view.backgroundColor = UIColor.white

        adapter.collectionView.contentInset.top = 48

        do {
            sortSelectionControl.backgroundColor = UIColor.white
            sortSelectionControl.selectedSegmentIndex = 1
            view.addSubview(sortSelectionControl)
            sortSelectionControl.pinEdges(to: view.safeAreaLayoutGuide, top: 8, left: 16, bottom: .nan, right: 16)
        }

        do {
            adapter.collectionEvents.didHighlightCell = { (cell, _) in
                UIView.animate(withDuration: 0.1, animations: {
                    cell.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
                })
            }

            adapter.collectionEvents.didUnhighlightCell = { (cell, _) in
                UIView.animate(withDuration: 0.15, animations: {
                    cell.transform = CGAffineTransform.identity
                })
            }

            adapter.scrollEvents.didScroll = { [weak self] scrollView in
                self?.isSortSelectionControlHidden = (scrollView.contentOffset.y + scrollView.adjustedContentInset.top) > 10
                
                if (scrollView.contentOffset.y / scrollView.contentSize.height) > 0.8 {
                    self?.interactor.loadNextPage()
                }
            }

            sortSelectionControl.all_setEventHandler(for: .valueChanged) { [weak self] in
                guard let strongSelf = self else { return }

                let selectedSegmentIndex = strongSelf.sortSelectionControl.selectedSegmentIndex

                let sort: ReviewsSort

                switch selectedSegmentIndex {
                case 0:
                    sort = .mark
                case 2:
                    sort = .rating
                default:
                    sort = .date
                }

                strongSelf.interactor.sort(by: sort)
            }
        }

        interactor.stateObservable
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .map { [weak self] state -> [ListItem] in
                return self?.makeListItemsFrom(state: state) ?? []
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.adapter.set(items: items)
            })
            .disposed(by: disposeBag)

        interactor.loadNextPage()
    }

    // MARK: -

    private var isSortSelectionControlHidden: Bool = false {
        didSet {
            guard isSortSelectionControlHidden != oldValue else {
                return
            }

            let alpha: CGFloat = isSortSelectionControlHidden ? 0 : 1
            let transform: CGAffineTransform = isSortSelectionControlHidden ? CGAffineTransform(translationX: 0, y: -40) : .identity

            UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: { [sortSelectionControl] in
                sortSelectionControl.alpha = alpha
                sortSelectionControl.transform = transform
            })
        }
    }

    private let loadingItemId = UUID().uuidString
    private let errorItemId = UUID().uuidString

    private func makeListItemsFrom(state: WorkReviewsInteractor.State) -> [ListItem] {
        var items: [ListItem] = state.reviews.map { review -> ListItem in
            let listItem = ListItem(
                id: String(review.id),
                model: String(review.id),
                layoutSpec: WorkReviewLayoutSpec(model: review)
            )

            listItem.actions.onSelect = { [weak self] in
                self?.open(review: review)
            }

            return listItem
        }

        switch state.status {
        case .loading:
            let item = ListItem(id: loadingItemId, model: loadingItemId, layoutSpec: SpinnerLayoutSpec())

            items.append(item)
        case .error:
        break // TODO:
        case .idle:
            break
        }

        return items
    }

    private func open(review: WorkReviewModel) {
        router.showInteractiveText(review.text, title: "Отзыв")
    }
}
