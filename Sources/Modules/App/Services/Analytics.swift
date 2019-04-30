import Foundation
#if !DEBUG
import Firebase
#endif

final class AppAnalytics {
    private init() {}

    private static func log(event name: String, params: [String: String] = [:]) {
        #if DEBUG
        print(name, params)
        #else
        Firebase.Analytics.logEvent(name, parameters: params)
        #endif
    }

    // MARK: -

    static func logWorkTabOpen(name: String) {
        log(event: "fl_work_tab_open", params: ["tab_name": name])
    }

    static func logShowAllReviewsButtonTap() {
        log(event: "fl_show_all_reviews_tap")
    }

    static func logShareButtonTap(url: URL) {
        log(event: "fl_share_button_tap", params: ["url": url.absoluteString])
    }

    static func logOpenWebVersionButtonTap(url: URL) {
        log(event: "fl_open_web_version_button_tap", params: ["url": url.absoluteString])
    }

    static func logWorkAuthorsTap() {
        log(event: "fl_work_authors_tap")
    }

    static func logGoHomeConfirmTap() {
        log(event: "fl_go_home_confirm_tap")
    }

    static func logScrollToBackgroundImage() {
        log(event: "fl_log_scroll_to_background_image")
    }

    static func logWorkInAwardListTap() {
        log(event: "fl_log_work_in_awards_tap")
    }

    static func logReviewsSortChange(name: String) {
        log(event: "fl_reviews_sort_change", params: ["sort_name": name])
    }

    static func logFreshReviewsRefresh() {
        log(event: "fl_fresh_reviews_refresh")
    }

    static func logNewsRefresh() {
        log(event: "fl_news_refresh")
    }

    enum BarcodeScannerSource: CustomStringConvertible {
        case mainScreen
        case searchScreen

        var description: String {
            switch self {
            case .mainScreen:
                return "Главный экран"
            case .searchScreen:
                return "Поиск"
            }
        }
    }

    static func logOpenBarcodeScanner(from source: BarcodeScannerSource) {
        log(event: "fl_open_barcode_scanner", params: ["source": source.description])
    }
}
