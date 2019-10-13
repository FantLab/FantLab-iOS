import Foundation
import UIKit
import ALLKit
import FLKit
import FLModels
import FLStyle
import FLLayoutSpecs
import FLText

public enum WorkContentTabIndex: String {
    case info
    case reviews
    case analogs
}

public struct WorkViewState {
    public let work: WorkModel
    public let workTree: WorkTreeNode
    public let analogs: [WorkPreviewModel]
    public var reviews: DataState<[WorkReviewModel]>
    public var tabIndex: WorkContentTabIndex

    public init(work: WorkModel,
                workTree: WorkTreeNode,
                analogs: [WorkPreviewModel],
                reviews: DataState<[WorkReviewModel]>,
                tabIndex: WorkContentTabIndex) {

        self.work = work
        self.workTree = workTree
        self.analogs = analogs
        self.reviews = reviews
        self.tabIndex = tabIndex
    }
}

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
    public typealias ModelType = WorkViewState

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

    public func makeListItemsFrom(model: WorkViewState) -> [ListItem] {
        let infoString = [model.work.descriptionText, model.work.notes].compactAndJoin("\n")

        let hasRating = model.work.rating > 0 && model.work.votes > 0
        let hasDescription = !infoString.isEmpty
        let hasClassification = !model.work.classificatory.isEmpty
        let hasAwards = !model.work.awards.isEmpty
        let parentsCount = model.work.parents.compactMap({ $0.count }).reduce(0, +)
        let childrenCount = model.workTree.count
        let hasEditions = model.work.editionBlocks.contains { !$0.list.isEmpty }
        let hasReviews = model.work.reviewsCount > 0
        let hasAnalogs = !model.analogs.isEmpty

        var items: [ListItem] = []

        // header

        do {
            let item = ListItem(
                id: "work_header",
                layoutSpec: WorkHeaderLayoutSpec(model: (model.work, { [weak self] in
                    self?.delegate?.onHeaderTap(work: model.work)
                }))
            )

            items.append(item)
        }

        // rating

        if hasRating {
            let item = ListItem(
                id: "work_rating",
                layoutSpec: WorkRatingLayoutSpec(model: model.work)
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
                            layoutSpec: FLTextPreviewLayoutSpec(model: FLStringPreview(string: infoString))
                        )

                        item.didTap = { [weak self] view, _ in
                            view.animated(action: {
                                self?.delegate?.onDescriptionTap(work: model.work)
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
                            layoutSpec: ObjectPropertiesLayoutSpec(model: model.work)
                        ))
                    }
                }

                sections.append(section)
            }

            if hasEditions {
                let count = model.work.editionBlocks.reduce(into: 0) {
                    $0 += $1.list.count
                }

                var editionList: [EditionPreviewModel] = []

                let maxCount = 10

                outer: for block in model.work.editionBlocks {
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
                        self?.delegate?.onEditionsTap(work: model.work)
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
                    count: model.work.awards.count,
                    hasArrow: true
                    ), tapAction: ({ [weak self] in
                        self?.delegate?.onAwardsTap(work: model.work)
                    })) {
                        let item = ListItem(
                            id: "work_awards",
                            layoutSpec: AwardIconsLayoutSpec(model: model.work.awards)
                        )

                        item.didTap = { [weak self] view, _ in
                            view.animated(action: {
                                self?.delegate?.onAwardsTap(work: model.work)
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
                            id: WorkTreeNodeListModel(
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
                            item.didTap = { [weak self] view, _ in
                                view.animated(action: {
                                    self?.delegate?.onWorkTap(id: work.id)
                                }, alpha: 0.3)
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
                    model.work.parents.forEach { parents in
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
                                item.didTap = { [weak self] view, _ in
                                    view.animated(action: {
                                        self?.delegate?.onWorkTap(id: parent.id)
                                    }, alpha: 0.3)
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
                    count: model.work.reviewsCount,
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
                id: model.tabIndex,
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
                        layoutSpec: EmptySpaceLayoutSpec(model: (Colors.sectionSeparatorColor, 8))
                    ))

                    let titleItem = ListItem(
                        id: sectionId + "_title",
                        layoutSpec: ListSectionTitleLayoutSpec(model: section.layoutModel)
                    )

                    if let tapAction = section.tapAction {
                        titleItem.didTap = { (view, _) in
                            view.animated(action: tapAction)
                        }
                    }

                    items.append(titleItem)
                }

                section.makeListItems()
            }
        case .reviews:
            let reviewsState = model.reviews.map {
                WorkReviewsShortListViewState(
                    work: model.work,
                    reviews: $0,
                    hasShowAllButton: $0.count < model.work.reviewsCount
                )
            }

            let reviewItems = reviewContentBuilder.makeListItemsFrom(model: reviewsState)

            items.append(contentsOf: reviewItems)
        case .analogs:
            model.analogs.forEach { analog in
                let itemId = "work_analog_\(analog.id)"

                let item = ListItem(
                    id: itemId,
                    layoutSpec: WorkPreviewLayoutSpec(model: analog)
                )

                item.didTap = { [weak self] view, _ in
                    view.animated(action: {
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
