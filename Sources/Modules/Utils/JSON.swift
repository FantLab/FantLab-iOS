import Foundation

@dynamicMemberLookup
public class JSON: CustomDebugStringConvertible, CustomStringConvertible {
    private let object: Any?

    public init(_ object: Any?) {
        self.object = object is NSNull ? nil : object
    }

    public convenience init?(jsonData: Data) {
        guard let object = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) else {
            return nil
        }

        self.init(object)
    }

    // MARK: -

    public var description: String {
        guard
            let object = object,
            let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
            let string = String(data: data, encoding: .utf8) else {
                return ""
        }

        return string
    }

    public var debugDescription: String {
        return description
    }

    // MARK: -

    public func exists() -> Bool {
        return object != nil
    }

    public var array: [JSON] {
        return (object as? [Any])?.map({ JSON($0) }) ?? []
    }

    public var keys: [String] {
        return (object as? [String: Any])?.keys.sorted() ?? []
    }

    // MARK: -

    public subscript(_ index: Int) -> JSON {
        return JSON((object as? [Any])?[safe: index])
    }

    public subscript(_ key: String) -> JSON {
        return JSON((object as? [String: Any])?[key])
    }

    // MARK: - dynamicMemberLookup

    public subscript(dynamicMember key: String) -> JSON {
        return self[key]
    }

    // MARK: -

    public var string: String? {
        return object as? String
    }

    public var bool: Bool? {
        return (object as? NSNumber)?.boolValue ?? (object as? NSString)?.boolValue
    }

    public var int: Int? {
        return (object as? NSNumber)?.intValue ?? (object as? NSString)?.integerValue
    }

    public var long: Int64? {
        return (object as? NSNumber)?.int64Value ?? (object as? NSString)?.longLongValue
    }

    public var float: Float? {
        return (object as? NSNumber)?.floatValue ?? (object as? NSString)?.floatValue
    }

    public var double: Double? {
        return (object as? NSNumber)?.doubleValue ?? (object as? NSString)?.doubleValue
    }
}

extension JSON {
    public var stringValue: String {
        return string ?? ""
    }

    public var boolValue: Bool {
        return bool ?? false
    }

    public var intValue: Int {
        return int ?? 0
    }

    public var longValue: Int64 {
        return long ?? 0
    }

    public var floatValue: Float {
        return float ?? 0
    }

    public var doubleValue: Double {
        return double ?? 0
    }
}
