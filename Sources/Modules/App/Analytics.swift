import Foundation
#if !DEBUG
import Firebase
#endif

final class AppAnalytics {
    private init() {}

    private static func log(event name: String, params: [String: Any]) {
        #if DEBUG
        print(name, params)
        #else
        Firebase.Analytics.logEvent(name, parameters: params)
        #endif
    }
}
