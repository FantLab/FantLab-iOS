import Foundation
import UIKit
import ALLKit
import FLKit

public final class EmptyContentBuilder: ListContentBuilder {
    public typealias ModelType = Void

    public func makeListItemsFrom(model: Void) -> [ListItem] {
        return []
    }
}
