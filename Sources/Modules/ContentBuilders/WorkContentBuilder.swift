import Foundation
import UIKit
import ALLKit
import FantLabUtils
import FantLabModels
import FantLabStyle
import FantLabLayoutSpecs

public enum WorkContentTabIndex: String, CustomStringConvertible {
    case info
    case reviews
    case analogs

    public var description: String {
        switch self {
        case .info:
            return "Обзор"
        case .reviews:
            return "Отзывы"
        case .analogs:
            return "Похожие"
        }
    }
}

struct DataModel {
    let work: WorkModel
    let analogs: [WorkPreviewModel]
    let contentRoot: WorkTreeNode
}

public typealias WorkContentModel = (info: WorkModel, reviews: DataState<WorkReviewsShortListContentModel>, analogs: [WorkPreviewModel], workTree: WorkTreeNode, tabIndex: WorkContentTabIndex)

public protocol WorkContentBuilderDelegate: class {
    func onHeaderTap(work: WorkModel)
    func onTabTap(tab: WorkContentTabIndex)
    func onDescriptionTap(work: WorkModel)
    func onExpandOrCollapse()
    func onWorkTap(id: Int)
    func onReviewUserTap(userId: Int)
    func onReviewTextTap(review: WorkReviewModel)
    func onShowAllReviewsTap(work: WorkModel)
    func onReviewsErrorTap()
    func onAwardsTap(work: WorkModel)
    func onEditionsTap(work: WorkModel)
    func onEditionTap(id: Int)
}

public final class WorkContentBuilder: ListContentBuilder {
    public typealias ModelType = WorkContentModel

    // MARK: -

    private let reviewContentBuilder = DataStateContentBuilder(dataContentBuilder: WorkReviewsShortListContentBuilder())

    public init() {
        reviewContentBuilder.dataContentBuilder.singleReviewContentBuilder.onReviewUserTap = { [weak self] userId in
            self?.delegate?.onReviewUserTap(userId: userId)
        }

        reviewContentBuilder.dataContentBuilder.singleReviewContentBuilder.onReviewTextTap = { [weak self] review in
            self?.delegate?.onReviewTextTap(review: review)
        }

        reviewContentBuilder.dataContentBuilder.onShowAllReviewsTap = { [weak self] work in
            self?.delegate?.onShowAllReviewsTap(work: work)
        }

        reviewContentBuilder.errorContentBuilder.onRetry = { [weak self] in
            self?.delegate?.onReviewsErrorTap()
        }
    }

    // MARK: -

    public weak var delegate: WorkContentBuilderDelegate?

    // MARK: -

    public func makeListItemsFrom(model: WorkContentModel) -> [ListItem] {
        let infoString = [model.info.descriptionText, model.info.notes].compactAndJoin("\n")

        let hasRating = model.info.rating > 0 && model.info.votes > 0
        let hasDescription = !infoString.isEmpty
        let hasClassification = !model.info.classificatory.isEmpty
        let hasAwards = !model.info.awards.isEmpty
        let parentsCount = model.info.parents.compactMap({ $0.count }).reduce(0, +)
        let childrenCount = model.workTree.count
        let hasEditions = model.info.editionBlocks.contains { !$0.list.isEmpty }
        let hasReviews = model.info.reviewsCount > 0
        let hasAnalogs = !model.analogs.isEmpty

        var items: [ListItem] = []

        // header

        do {
            let item = ListItem(
                id: "work_header",
                layoutSpec: WorkHeaderLayoutSpec(model: model.info)
            )

            item.didSelect = { [weak self] cell, _ in
                self?.delegate?.onHeaderTap(work: model.info)
            }

            items.append(item)
        }

        // rating

        if hasRating {
            let item = ListItem(
                id: "work_rating",
                layoutSpec: WorkRatingLayoutSpec(model: model.info)
            )

            items.append(item)
        }

        // sections

        var sections: [SectionListModel] = []

        do {
            if hasDescription || hasClassification {
                let section = SectionListModel(layoutModel: ListSectionTitleLayoutModel(
                    title: "Обзор",
                    count: 0,
                    hasArrow: false
                ), tapAction: nil) {
                    if hasDescription {
                        let item = ListItem(
                            id: "work_description",
                            layoutSpec: FLTextPreviewLayoutSpec(model: infoString)
                        )

                        item.didSelect = { [weak self] cell, _ in
                            CellSelection.scale(cell: cell, action: {
                                self?.delegate?.onDescriptionTap(work: model.info)
                            })
                        }

                        items.append(item)
                    }

                    if hasClassification {
                        if hasDescription {
                            items.append(ListItem(
                                id: "work_classification_sep",
                                layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
                            ))
                        }

                        items.append(ListItem(
                            id: "work_classification",
                            layoutSpec: WorkGenresLayoutSpec(model: model.info)
                        ))
                    }
                }

                sections.append(section)
            }

            if hasEditions {
                let count = model.info.editionBlocks.reduce(into: 0) {
                    $0 += $1.list.count
                }

                var editionList: [EditionPreviewModel] = []

                let maxCount = 10

                outer: for block in model.info.editionBlocks {
                    for edition in block.list {
                        editionList.append(edition)

                        if editionList.count == maxCount {
                            break outer
                        }
                    }
                }

                let section = SectionListModel(layoutModel: ListSectionTitleLayoutModel(
                    title: "Издания",
                    count: count,
                    hasArrow: true
                    ), tapAction: ({ [weak self] in
                        self?.delegate?.onEditionsTap(work: model.info)
                    })) {
                        let item = ListItem(
                            id: "work_editions",
                            layoutSpec: EditionListLayoutSpec(model: (editionList, ({ [weak self] editionId in
                                self?.delegate?.onEditionTap(id: editionId)
                            })))
                        )

                        items.append(item)
                }

                sections.append(section)
            }

            if hasAwards {
                let section = SectionListModel(layoutModel: ListSectionTitleLayoutModel(
                    title: "Премии",
                    count: model.info.awards.count,
                    hasArrow: true
                    ), tapAction: ({ [weak self] in
                        self?.delegate?.onAwardsTap(work: model.info)
                    })) {
                        let item = ListItem(
                            id: "work_awards",
                            layoutSpec: AwardIconsLayoutSpec(model: model.info.awards)
                        )

                        item.didSelect = { [weak self] cell, _ in
                            CellSelection.scale(cell: cell, action: {
                                self?.delegate?.onAwardsTap(work: model.info)
                            })
                        }

                        items.append(item)
                }

                sections.append(section)
            }

            if childrenCount > 0 {
                let section = SectionListModel(layoutModel: ListSectionTitleLayoutModel(
                    title: "Содержание",
                    count: childrenCount,
                    hasArrow: false
                ), tapAction: nil) {
                    model.workTree.traverseContent { node in
                        guard let work = node.model else {
                            return
                        }

                        let nodeId = "work_tree_node_" + String(node.id)

                        let item = ListItem(
                            id: nodeId,
                            model: WorkTreeNodeListModel(
                                id: nodeId,
                                isExpanded: node.isExpanded
                            ),
                            layoutSpec: ChildWorkLayoutSpec(model: ChildWorkLayoutModel(
                                work: work,
                                count: node.children.count,
                                isExpanded: node.isExpanded,
                                expandCollapseAction: node.count > 0 ? ({ [weak self] in
                                    node.isExpanded = !node.isExpanded

                                    self?.delegate?.onExpandOrCollapse()
                                }) : nil
                            ))
                        )

                        if work.id > 0 {
                            item.didSelect = { [weak self] cell, _ in
                                CellSelection.alpha(cell: cell, action: {
                                    self?.delegate?.onWorkTap(id: work.id)
                                })
                            }
                        }

                        items.append(item)

                        items.append(ListItem(
                            id: nodeId + "_sep",
                            layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
                        ))
                    }

                    items.removeLast()
                }

                sections.append(section)
            }

            if parentsCount > 0 {
                let section = SectionListModel(layoutModel: ListSectionTitleLayoutModel(
                    title: "Входит в",
                    count: parentsCount,
                    hasArrow: false
                ), tapAction: nil) {
                    model.info.parents.forEach { parents in
                        parents.enumerated().forEach({ (index, parent) in
                            let itemId = "work_parent_\(parent.id)"

                            let item = ListItem(
                                id: itemId,
                                layoutSpec: WorkParentModelLayoutSpec(model: WorkParentModelLayoutModel(
                                    work: parent,
                                    level: index,
                                    showArrow: parent.id > 0
                                ))
                            )

                            if parent.id > 0 {
                                item.didSelect = { [weak self] cell, _ in
                                    CellSelection.alpha(cell: cell, action: {
                                        self?.delegate?.onWorkTap(id: parent.id)
                                    })
                                }
                            }

                            items.append(item)

                            items.append(ListItem(
                                id: itemId + "_sep",
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
                isSelected: model.tabIndex == .info,
                action: ({ [weak self] in
                    self?.delegate?.onTabTap(tab: .info)
                })
            ))

            if hasReviews {
                tabs.append(TabLayoutModel(
                    name: "Отзывы",
                    count: model.info.reviewsCount,
                    isSelected: model.tabIndex == .reviews,
                    action: ({ [weak self] in
                        self?.delegate?.onTabTap(tab: .reviews)
                    })
                ))
            }

            if hasAnalogs {
                tabs.append(TabLayoutModel(
                    name: "Похожие",
                    count: model.analogs.count,
                    isSelected: model.tabIndex == .analogs,
                    action: ({ [weak self] in
                        self?.delegate?.onTabTap(tab: .analogs)
                    })
                ))
            }

            let item = ListItem(
                id: "work_tabs",
                model: model.tabIndex,
                layoutSpec: TabsLayoutSpec(model: tabs)
            )

            items.append(item)
        }

        switch model.tabIndex {
        case .info:
            sections.enumerated().forEach { (index, section) in
                let sectionId = "work_section_" + section.layoutModel.title

                if index > 0 || !hasTabs {
                    items.append(ListItem(
                        id: sectionId + "_sep",
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
            let reviewItems = reviewContentBuilder.makeListItemsFrom(model: model.reviews)

            items.append(contentsOf: reviewItems)
        case .analogs:
            model.analogs.forEach { analog in
                let itemId = "work_analog_\(analog.id)"

                let item = ListItem(
                    id: itemId,
                    layoutSpec: WorkPreviewLayoutSpec(model: analog)
                )

                item.didSelect = { [weak self] cell, _ in
                    CellSelection.scale(cell: cell, action: {
                        self?.delegate?.onWorkTap(id: analog.id)
                    })
                }

                items.append(item)

                items.append(ListItem(
                    id: itemId + "_sep",
                    layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
                ))
            }
        }

        return items
    }
}
