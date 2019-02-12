import Foundation
import UIKit
import ALLKit
import FantLabUtils
import FantLabModels
import FantLabStyle
import FantLabLayoutSpecs

public typealias AuthorContentModel = (info: AuthorModel, workTree: WorkTreeNode)

public protocol AuthorContentBuilderDelegate: class {
    func onDescriptionTap(author: AuthorModel)
    func onExpandOrCollapse()
    func onWorkTap(id: Int)
    func onAwardsTap(author: AuthorModel)
    func onURLTap(url: URL)
}

public final class AuthorContentBuilder: ListContentBuilder {
    public typealias ModelType = AuthorContentModel

    // MARK: -

    public init() {}

    // MARK: -

    public weak var delegate: AuthorContentBuilderDelegate?

    // MARK: -

    public func makeListItemsFrom(model: AuthorContentModel) -> [ListItem] {
        var items: [ListItem] = []

        // хедер

        do {
            let item = ListItem(
                id: "author_header",
                layoutSpec: AuthorHeaderLayoutSpec(model: model.info)
            )

            items.append(item)
        }

        // биография

        let info = [model.info.bio, model.info.notes].compactAndJoin("\n")

        if !info.isEmpty {
            items.append(ListItem(
                id: "author_bio_sep",
                layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
            ))

            let item = ListItem(
                id: "author_bio",
                layoutSpec: FLTextPreviewLayoutSpec(model: info)
            )

            item.didSelect = { [weak self] cell, _ in
                CellSelection.scale(cell: cell, action: {
                    self?.delegate?.onDescriptionTap(author: model.info)
                })
            }

            items.append(item)
        }

        // сайты

        model.info.sites.enumerated().forEach { (index, webSite) in
            guard let url = URL(string: webSite.link), !webSite.title.isEmpty else {
                return
            }

            let itemId = "author_website_\(index)"

            items.append(ListItem(
                id: itemId + "_sep",
                layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
            ))

            let item = ListItem(
                id: itemId,
                layoutSpec: AuthorWebSiteLayoutSpec(model: webSite)
            )

            item.didSelect = { [weak self] cell, _ in
                CellSelection.scale(cell: cell, action: {
                    self?.delegate?.onURLTap(url: url)
                })
            }

            items.append(item)
        }

        // sections

        var sections: [SectionListModel] = []

        if !model.info.awards.isEmpty {
            let section = SectionListModel(layoutModel: ListSectionTitleLayoutModel(
                title: "Премии",
                count: model.info.awards.count,
                hasArrow: true
                ), tapAction: ({ [weak self] in
                    self?.delegate?.onAwardsTap(author: model.info)
                })) {
                    let item = ListItem(
                        id: "author_awards",
                        layoutSpec: AwardIconsLayoutSpec(model: model.info.awards)
                    )

                    item.didSelect = { [weak self] cell, _ in
                        CellSelection.scale(cell: cell, action: {
                            self?.delegate?.onAwardsTap(author: model.info)
                        })
                    }

                    items.append(item)
            }

            sections.append(section)
        }

        if model.workTree.count > 0 {
            let section = SectionListModel(layoutModel: ListSectionTitleLayoutModel(
                title: "Произведения",
                count: 0,
                hasArrow: false
            ), tapAction: nil) {
                model.workTree.traverseContent { node in
                    guard let work = node.model else {
                        return
                    }

                    let nodeId = "work_tree_node_\(node.id)"

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

        sections.enumerated().forEach { (index, section) in
            let sectionId = "author_section_" + section.layoutModel.title

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

            section.makeListItems()
        }

        return items
    }
}
