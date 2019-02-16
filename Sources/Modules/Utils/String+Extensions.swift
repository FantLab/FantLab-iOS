import Foundation

extension String {
    public func capitalizedFirstLetter() -> String {
        return isEmpty ? "" : prefix(1).capitalized + dropFirst()
    }

    public var nilIfEmpty: String? {
        return isEmpty ? nil : self
    }

    public var maybeHasContent: Bool {
        if count < 10 {
            return contains(where: {
                if let unicodeScalar = $0.unicodeScalars.first {
                    return CharacterSet.newlines.inverted.contains(unicodeScalar)
                }

                return false
            })
        }

        return true
    }

    public func firstMatch(for pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }

        guard let result = regex.firstMatch(in: self, range: NSRange(startIndex..., in: self)), let range = Range(result.range, in: self) else {
            return nil
        }

        return String(self[range])
    }

    public func detectURLs() -> [(URL, NSRange)] {
        guard let linkDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return []
        }

        let matches = linkDetector.matches(in: self, range: NSRange(startIndex..., in: self))

        return matches.compactMap({
            guard let url = $0.url else {
                return nil
            }

            return (url, $0.range)
        })
    }
}

extension Array where Element == String {
    public func compactAndJoin(_ separator: String) -> String {
        return compactMap({ $0.nilIfEmpty }).joined(separator: separator)
    }
}

extension Range where Bound == String.Index {
    public var nsRange: NSRange {
        return NSMakeRange(lowerBound.encodedOffset, upperBound.encodedOffset - lowerBound.encodedOffset)
    }
}
