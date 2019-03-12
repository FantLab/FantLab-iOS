public typealias ObjectProperty = (name: String, value: String)

public protocol ObjectPropertiesProvider {
    var objectProperties: [ObjectProperty] { get }
}
