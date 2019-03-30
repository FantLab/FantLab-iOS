import Foundation
import UIKit
import ALLKit
import FLKit
import FLModels
import FLStyle
import FLLayoutSpecs

public final class SearchResultContentBuilder: ListContentBuilder {
    public typealias ModelType = SearchResultModel
    
    // MARK: -
    
    public init() {}
    
    // MARK: -
    
    public var onAuthorTap: ((Int) -> Void)?
    public var onWorkTap: ((Int) -> Void)?
    
    // MARK: -
    
    private let notFoundId = UUID().uuidString
    
    // MARK: -
    
    public func makeListItemsFrom(model: SearchResultModel) -> [ListItem] {
        if model.searchText.isEmpty {
            return []
        }
        
        if model.authors.isEmpty && model.works.isEmpty {
            let text = "По запросу «\(model.searchText)» ничего не найдено"
            
            let item = ListItem(
                id: notFoundId,
                model: model.searchText,
                layoutSpec: ErrorDescriptionLayoutSpec(model: (UIImage(named: "not_found")!, text))
            )
            
            return [item]
        }
        
        var items: [ListItem] = []
        
        model.authors.forEach { author in
            let item = ListItem(
                id: "author_\(author.id)",
                layoutSpec: AuthorPreviewLayoutSpec(model: author)
            )
            
            item.didTap = { [weak self] view, _ in
                view.animated(action: {
                    self?.onAuthorTap?(author.id)
                })
            }
            
            items.append(item)
            
            items.append(ListItem(
                id: "author_\(author.id)_sep",
                layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
            ))
        }
        
        if !model.authors.isEmpty && !model.works.isEmpty {
            items.removeLast()
            
            items.append(ListItem(
                id: "authors_works_sep",
                layoutSpec: EmptySpaceLayoutSpec(model: (Colors.perfectGray, 8))
            ))
        }
        
        model.works.forEach { work in
            let item = ListItem(
                id: "work_\(work.id)",
                layoutSpec: WorkPreviewLayoutSpec(model: work)
            )
            
            item.didTap = { [weak self] view, _ in
                view.animated(action: {
                    self?.onWorkTap?(work.id)
                })
            }
            
            items.append(item)
            
            items.append(ListItem(
                id: "work_\(work.id)_sep",
                layoutSpec: ItemSeparatorLayoutSpec(model: Colors.separatorColor)
            ))
        }
        
        return items
    }
}
