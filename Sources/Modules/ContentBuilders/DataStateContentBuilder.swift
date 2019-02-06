import Foundation
import UIKit
import ALLKit
import FantLabStyle
import FantLabUtils
import FantLabLayoutSpecs

public final class DataStateContentBuilder<DataType, BuilderType: ListContentBuilder>: ListContentBuilder where BuilderType.ModelType == DataType {
    public typealias ModelType = DataState<DataType>

    public init(dataContentBuilder: BuilderType) {
        self.dataContentBuilder = dataContentBuilder
    }

    public let dataContentBuilder: BuilderType
    public let errorContentBuilder = ErrorContentBuilder()

    private let loadingId = UUID().uuidString
    private let errorId = UUID().uuidString

    public func makeListItemsFrom(model: DataState<DataType>) -> [ListItem] {
        switch model {
        case .initial:
            return []
        case .loading:
            return [ListItem(id: loadingId, layoutSpec: SpinnerLayoutSpec())]
        case let .error(error):
            return errorContentBuilder.makeListItemsFrom(model: error)
        case let .idle(data):
            return dataContentBuilder.makeListItemsFrom(model: data)
        }
    }
}
