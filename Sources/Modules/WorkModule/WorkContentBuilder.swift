import Foundation
import UIKit
import ALLKit
import FantLabModels
import FantLabSharedUI
import FantLabStyle

final class WorkContentBuilder {
    private struct WorkChildListModel: Equatable {
        let id: String
        let isExpanded: Bool
    }

    private struct SectionModel {
        let name: String
        let count: Int
        let makeListItems: () -> Void
    }

    // MARK: -

    var onHeaderTap: ((WorkModel) -> Void)?
    var onTabTap: ((TabIndex) -> Void)?
    var onDescriptionTap: ((WorkModel) -> Void)?
    var onExpandOrCollapse: (() -> Void)?
    var onChildWorkTap: ((Int) -> Void)?
    var onParentWorkTap: ((Int) -> Void)?
    var onReviewTap: ((WorkReviewModel) -> Void)?
    var onShowAllReviewsTap: ((WorkModel) -> Void)?
    var onWorkAnalogTap: ((Int) -> Void)?

    // MARK: -

    func makeListItemsFrom(state: DataState<WorkInteractor.DataModel>,
                           reviewsState: DataState<[WorkReviewModel]>,
                           tabIndex: TabIndex) -> [ListItem] {
        switch state {
        case .initial:
            return []
        case .loading:
            return [ListItem(id: "work_loading", layoutSpec: SpinnerLayoutSpec())]
        case .error:
            return [] // TODO:
        case let .idle(data):
            return makeListItemsFrom(data: data, reviewsState: reviewsState, tabIndex: tabIndex)
        }
    }

    private func makeListItemsFrom(data: WorkInteractor.DataModel,
                                   reviewsState: DataState<[WorkReviewModel]>,
                                   tabIndex: TabIndex) -> [ListItem] {
        let workId = String(data.work.id)

        var items: [ListItem] = []

        // header

        do {
            let item = ListItem(
                id: workId + "_header",
                layoutSpec: WorkHeaderLayoutSpec(model: data.work)
            )

            item.didSelect = { [weak self] _ in
                self?.onHeaderTap?(data.work)
            }

            items.append(item)
        }

        // rating

        let hasRating = data.work.rating > 0 && data.work.votes > 0

        if hasRating {
            let item = ListItem(
                id: workId + "_rating",
                layoutSpec: WorkRatingLayoutSpec(model: data.work)
            )

            items.append(item)
        }

        // sections

        var sections: [SectionModel] = []

        do {
            let hasDescription = !data.work.descriptionText.isEmpty || !data.work.notes.isEmpty
            let hasClassification = !data.work.classificatory.isEmpty
            let parentsCount = data.work.parents.compactMap({ $0.count }).reduce(0, +)
            let childrenCount = data.contentRoot.count

            if hasDescription || hasClassification {
                let section = SectionModel(name: "Обзор", count: 0) {
                    if hasDescription {
                        let item = ListItem(
                            id: workId + "_description",
                            layoutSpec: WorkDescriptionLayoutSpec(model: data.work)
                        )

                        item.didSelect = { [weak self] cell in
                            CellSelection.scale(cell: cell, action: {
                                self?.onDescriptionTap?(data.work)
                            })
                        }

                        items.append(item)
                    }

                    if hasClassification {
                        if hasDescription {
                            items.append(ListItem(
                                id: workId + "_classification_separator",
                                layoutSpec: ItemSeparatorLayoutSpec()
                            ))
                        }

                        items.append(ListItem(
                            id: workId + "_classification",
                            layoutSpec: WorkGenresLayoutSpec(model: data.work)
                        ))
                    }
                }

                sections.append(section)
            }

            if parentsCount > 0 {
                let section = SectionModel(name: "Входит в", count: parentsCount) {
                    data.work.parents.forEach { parents in
                        parents.enumerated().forEach({ (index, parentModel) in
                            let itemId = workId + "_parent_" + String(parentModel.id)

                            let item = ListItem(
                                id: itemId,
                                layoutSpec: WorkParentModelLayoutSpec(model: WorkParentModelLayoutModel(
                                    work: parentModel,
                                    level: index,
                                    showArrow: parentModel.id > 0
                                ))
                            )

                            if parentModel.id > 0 {
                                item.didSelect = { [weak self] cell in
                                    CellSelection.alpha(cell: cell, action: {
                                        self?.onParentWorkTap?(parentModel.id)
                                    })
                                }
                            }

                            items.append(item)

                            items.append(ListItem(
                                id: itemId + "_separator",
                                layoutSpec: ItemSeparatorLayoutSpec()
                            ))
                        })
                    }

                    items.removeLast()
                }

                sections.append(section)
            }

            if childrenCount > 0 {
                let section = SectionModel(name: "Содержание", count: childrenCount) {
                    data.contentRoot.traverseContent { node in
                        guard let work = node.model else {
                            return
                        }

                        let nodeId = "child_node_" + String(node.id)

                        let item = ListItem(
                            id: nodeId,
                            model: WorkChildListModel(
                                id: nodeId,
                                isExpanded: node.isExpanded
                            ),
                            layoutSpec: WorkChildLayoutSpec(model: WorkChildLayoutModel(
                                work: work,
                                count: node.count,
                                isExpanded: node.isExpanded,
                                expandCollapseAction: node.count > 0 ? ({ [weak self] in
                                    node.isExpanded = !node.isExpanded

                                    self?.onExpandOrCollapse?()
                                }) : nil
                            ))
                        )

                        if work.id > 0 {
                            item.didSelect = { [weak self] cell in
                                CellSelection.alpha(cell: cell, action: {
                                    self?.onChildWorkTap?(work.id)
                                })
                            }
                        }

                        items.append(item)

                        items.append(ListItem(
                            id: nodeId + "_separator",
                            layoutSpec: ItemSeparatorLayoutSpec()
                        ))
                    }

                    items.removeLast()
                }

                sections.append(section)
            }
        }

        // check sections

        guard !sections.isEmpty else {
            return items
        }

        // main tabs

        let hasTabs: Bool

        do {
            let hasReviews = data.work.reviewsCount > 0
            let hasAnalogs = !data.analogs.isEmpty

            hasTabs = hasReviews || hasAnalogs

            if hasTabs {
                var tabs: [WorkTabLayoutModel] = []

                tabs.append(WorkTabLayoutModel(
                    name: sections[0].name,
                    count: sections[0].count,
                    isSelected: tabIndex == .info,
                    action: ({ [weak self] in
                        self?.onTabTap?(.info)
                    })
                ))

                if hasReviews {
                    tabs.append(WorkTabLayoutModel(
                        name: "Отзывы",
                        count: data.work.reviewsCount,
                        isSelected: tabIndex == .reviews,
                        action: ({ [weak self] in
                            self?.onTabTap?(.reviews)
                        })
                    ))
                }

                if hasAnalogs {
                    tabs.append(WorkTabLayoutModel(
                        name: "Похожие",
                        count: data.analogs.count,
                        isSelected: tabIndex == .analogs,
                        action: ({ [weak self] in
                            self?.onTabTap?(.analogs)
                        })
                    ))
                }

                let item = ListItem(
                    id: workId + "_tabs_" + tabIndex.rawValue,
                    layoutSpec: WorkTabsLayoutSpec(model: tabs)
                )

                items.append(item)
            }
        }

        switch tabIndex {
        case .info:
            sections.enumerated().forEach { (index, section) in
                let sectionId = workId + "_" + section.name

                if index > 0 || !hasTabs {
                    items.append(ListItem(
                        id: sectionId + "_separator",
                        layoutSpec: EmptySpaceLayoutSpec(model: (Colors.perfectGray, 8))
                    ))

                    items.append(ListItem(
                        id: sectionId + "_title",
                        layoutSpec: WorkSectionTitleLayoutSpec(model: (section.name, section.count))
                    ))
                }

                section.makeListItems()
            }
        case .reviews:
            switch reviewsState {
            case .initial:
                break
            case .loading:
                items.append(ListItem(id: "reviews_loading", layoutSpec: SpinnerLayoutSpec()))
            case .error:
            break // TODO:
            case let .idle(reviews):
                reviews.prefix(5).forEach { review in
                    let itemId = "review_" + String(review.id)

                    let headerItem = ListItem(
                        id: itemId + "_header",
                        layoutSpec: WorkReviewHeaderLayoutSpec(model: review)
                    )

                    let textItem = ListItem(
                        id: itemId + "_text",
                        layoutSpec: WorkReviewTextLayoutSpec(model: review)
                    )

                    textItem.didSelect = { [weak self] cell in
                        CellSelection.scale(cell: cell, action: {
                            self?.onReviewTap?(review)
                        })
                    }

                    items.append(headerItem)
                    items.append(textItem)

                    items.append(ListItem(
                        id: itemId + "_separator",
                        layoutSpec: ItemSeparatorLayoutSpec()
                    ))
                }

                if data.work.reviewsCount > reviews.count {
                    let item = ListItem(
                        id: "reviews_show_all_btn",
                        layoutSpec: WorkShowAllReviewsLayoutSpec()
                    )

                    item.didSelect = { [weak self] cell in
                        CellSelection.scale(cell: cell, action: {
                            self?.onShowAllReviewsTap?(data.work)
                        })
                    }

                    items.append(item)
                }
            }
        case .analogs:
            data.analogs.forEach { analog in
                let itemId = "analog_" + String(analog.id)
                
                let item = ListItem(
                    id: itemId,
                    layoutSpec: WorkAnalogLayoutSpec(model: analog)
                )

                item.didSelect = { [weak self] cell in
                    CellSelection.scale(cell: cell, action: {
                        self?.onWorkAnalogTap?(analog.id)
                    })
                }

                items.append(item)

                items.append(ListItem(
                    id: itemId + "_separator",
                    layoutSpec: ItemSeparatorLayoutSpec()
                ))
            }
        }

        return items
    }
}
