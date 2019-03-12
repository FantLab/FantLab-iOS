import Foundation
import UIKit
import ALLKit
import FLStyle
import FLKit
import FLLayoutSpecs

public final class DataStateContentBuilder<BuilderType: ListContentBuilder>: ListContentBuilder {
    public typealias ModelType = DataState<BuilderType.ModelType>

    public init(dataContentBuilder: BuilderType) {
        self.dataContentBuilder = dataContentBuilder
    }

    public let dataContentBuilder: BuilderType
    public let errorContentBuilder = ErrorContentBuilder()

    private let loadingId = UUID().uuidString
    private let errorId = UUID().uuidString

    public func makeListItemsFrom(model: DataState<BuilderType.ModelType>) -> [ListItem] {
        switch model {
        case .initial:
            return []
        case .loading:
            return [ListItem(id: loadingId, layoutSpec: SpinnerLayoutSpec())]
        case let .error(error):
            return errorContentBuilder.makeListItemsFrom(model: error)
        case let .success(data):
            return dataContentBuilder.makeListItemsFrom(model: data)
        }
    }
}
