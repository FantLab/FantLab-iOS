import Foundation
import UIKit
import ALLKit
import FantLabUtils
import FantLabModels
import FantLabStyle
import FantLabLayoutSpecs

final class WorkContentBuilder {
    private struct WorkChildListModel: Equatable {
        let id: String
        let isExpanded: Bool
    }

    private struct SectionModel {
        let layoutModel: ListSectionTitleLayoutModel
        let tapAction: (() -> Void)?
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
    var onAwardsTap: ((WorkModel) -> Void)?
    var onEditionsTap: ((WorkModel) -> Void)?

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

        let infoString = [data.work.descriptionText, data.work.notes].compactAndJoin("\n")

        let hasRating = data.work.rating > 0 && data.work.votes > 0
        let hasDescription = !infoString.isEmpty
        let hasClassification = !data.work.classificatory.isEmpty
        let hasAwards = !data.work.awards.isEmpty
        let parentsCount = data.work.parents.compactMap({ $0.count }).reduce(0, +)
        let childrenCount = data.contentRoot.count
        let hasEditions = data.work.editionBlocks.contains { !$0.list.isEmpty }
        let hasReviews = data.work.reviewsCount > 0
        let hasAnalogs = !data.analogs.isEmpty

        var items: [ListItem] = []

        // header

        do {
            let item = ListItem(
                id: workId + "_header",
                layoutSpec: WorkHeaderLayoutSpec(model: data.work)
            )

            item.didSelect = { [weak self] cell, _ in
                CellSelection.alpha(cell: cell, action: {
                    self?.onHeaderTap?(data.work)
                })
            }

            items.append(item)
        }

        // rating

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
            if hasDescription || hasClassification {
                let section = SectionModel(layoutModel: ListSectionTitleLayoutModel(
                    title: "Обзор",
                    count: 0,
                    hasArrow: false
                ), tapAction: nil) {
                    if hasDescription {
                        let item = ListItem(
                            id: workId + "_description",
                            layoutSpec: FLTextPreviewLayoutSpec(model: infoString)
                        )

                        item.didSelect = { [weak self] cell, _ in
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
                                layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
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

            if hasEditions {
                let count = data.work.editionBlocks.reduce(into: 0) {
                    $0 += $1.list.count
                }

                var editionList: [EditionPreviewModel] = []

                let maxCount = 10

                outer: for block in data.work.editionBlocks {
                    for edition in block.list {
                        editionList.append(edition)

                        if editionList.count == maxCount {
                            break outer
                        }
                    }
                }

                let section = SectionModel(layoutModel: ListSectionTitleLayoutModel(
                    title: "Издания",
                    count: count,
                    hasArrow: true
                    ), tapAction: ({ [weak self] in
                        self?.onEditionsTap?(data.work)
                    })) {
                        let item = ListItem(
                            id: workId + "_editions",
                            layoutSpec: EditionListLayoutSpec(model: editionList)
                        )

                        items.append(item)
                }

                sections.append(section)
            }

            if hasAwards {
                let section = SectionModel(layoutModel: ListSectionTitleLayoutModel(
                    title: "Премии",
                    count: data.work.awards.count,
                    hasArrow: true
                    ), tapAction: ({ [weak self] in
                        self?.onAwardsTap?(data.work)
                    })) {
                        let item = ListItem(
                            id: workId + "_awards",
                            layoutSpec: AwardIconsLayoutSpec(model: data.work.awards)
                        )

                        item.didSelect = { [weak self] cell, _ in
                            CellSelection.scale(cell: cell, action: {
                                self?.onAwardsTap?(data.work)
                            })
                        }

                        items.append(item)
                }

                sections.append(section)
            }

            if childrenCount > 0 {
                let section = SectionModel(layoutModel: ListSectionTitleLayoutModel(
                    title: "Содержание",
                    count: childrenCount,
                    hasArrow: false
                ), tapAction: nil) {
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
                            layoutSpec: ChildWorkLayoutSpec(model: ChildWorkLayoutModel(
                                work: work,
                                count: node.children.count,
                                isExpanded: node.isExpanded,
                                expandCollapseAction: node.count > 0 ? ({ [weak self] in
                                    node.isExpanded = !node.isExpanded

                                    self?.onExpandOrCollapse?()
                                }) : nil
                            ))
                        )

                        if work.id > 0 {
                            item.didSelect = { [weak self] cell, _ in
                                CellSelection.alpha(cell: cell, action: {
                                    self?.onChildWorkTap?(work.id)
                                })
                            }
                        }

                        items.append(item)

                        items.append(ListItem(
                            id: nodeId + "_separator",
                            layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
                        ))
                    }

                    items.removeLast()
                }

                sections.append(section)
            }

            if parentsCount > 0 {
                let section = SectionModel(layoutModel: ListSectionTitleLayoutModel(
                    title: "Входит в",
                    count: parentsCount,
                    hasArrow: false
                ), tapAction: nil) {
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
                                item.didSelect = { [weak self] cell, _ in
                                    CellSelection.alpha(cell: cell, action: {
                                        self?.onParentWorkTap?(parentModel.id)
                                    })
                                }
                            }

                            items.append(item)

                            items.append(ListItem(
                                id: itemId + "_separator",
                                layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
                            ))
                        })
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

        let hasTabs = hasReviews || hasAnalogs

        if hasTabs {
            var tabs: [TabLayoutModel] = []

            tabs.append(TabLayoutModel(
                name: sections[0].layoutModel.title,
                count: sections[0].layoutModel.count,
                isSelected: tabIndex == .info,
                action: ({ [weak self] in
                    self?.onTabTap?(.info)
                })
            ))

            if hasReviews {
                tabs.append(TabLayoutModel(
                    name: "Отзывы",
                    count: data.work.reviewsCount,
                    isSelected: tabIndex == .reviews,
                    action: ({ [weak self] in
                        self?.onTabTap?(.reviews)
                    })
                ))
            }

            if hasAnalogs {
                tabs.append(TabLayoutModel(
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
                layoutSpec: TabsLayoutSpec(model: tabs)
            )

            items.append(item)
        }

        switch tabIndex {
        case .info:
            sections.enumerated().forEach { (index, section) in
                let sectionId = workId + "_" + section.layoutModel.title

                if index > 0 || !hasTabs {
                    items.append(ListItem(
                        id: sectionId + "_separator",
                        layoutSpec: EmptySpaceLayoutSpec(model: (Colors.perfectGray, 8))
                    ))

                    let titleItem = ListItem(
                        id: sectionId + "_title",
                        layoutSpec: ListSectionTitleLayoutSpec(model: section.layoutModel)
                    )

                    if let tapAction = section.tapAction {
                        titleItem.didSelect = { (cell, _) in
                            CellSelection.scale(cell: cell, action: tapAction)
                        }
                    }

                    items.append(titleItem)
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

                    textItem.didSelect = { [weak self] cell, _ in
                        CellSelection.scale(cell: cell, action: {
                            self?.onReviewTap?(review)
                        })
                    }

                    items.append(headerItem)
                    items.append(textItem)

                    items.append(ListItem(
                        id: itemId + "_separator",
                        layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
                    ))
                }

                if data.work.reviewsCount > reviews.count {
                    let item = ListItem(
                        id: "reviews_show_all_btn",
                        layoutSpec: ShowAllButtonLayoutSpec(model: "Все отзывы")
                    )

                    item.didSelect = { [weak self] cell, _ in
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
                    layoutSpec: WorkPreviewLayoutSpec(model: analog)
                )

                item.didSelect = { [weak self] cell, _ in
                    CellSelection.scale(cell: cell, action: {
                        self?.onWorkAnalogTap?(analog.id)
                    })
                }

                items.append(item)

                items.append(ListItem(
                    id: itemId + "_separator",
                    layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
                ))
            }
        }

        return items
    }
}
