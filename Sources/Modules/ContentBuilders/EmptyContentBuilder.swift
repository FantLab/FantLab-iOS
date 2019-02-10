import Foundation
import UIKit
import ALLKit
import FantLabUtils

public final class EmptyContentBuilder: ListContentBuilder {
    public typealias ModelType = Void

    public func makeListItemsFrom(model: Void) -> [ListItem] {
        return []
    }
}
