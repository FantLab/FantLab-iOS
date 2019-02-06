import Foundation
import ALLKit

public protocol ListContentBuilder {
    associatedtype ModelType

    func makeListItemsFrom(model: ModelType) -> [ListItem]
}
