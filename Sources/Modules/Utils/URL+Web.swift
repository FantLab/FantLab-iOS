import Foundation

extension URL {
    public var isWebSafe: Bool {
        return host != nil && (scheme == "http" || scheme == "https")
    }

    public static func web(_ string: String, host: String? = nil) -> URL? {
        guard var components = URLComponents(string: string) else {
            return nil
        }

        if components.scheme == nil {
            components.scheme = "https"
        }

        if components.host == nil {
            components.host = host
        }

        if let webURL = components.url, webURL.isWebSafe {
            return webURL
        }

        return nil
    }
}
