import Foundation

public protocol WebURLProvider: class {
    var webURL: URL? { get }
}
